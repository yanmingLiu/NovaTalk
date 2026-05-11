import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';

import '../../generated/assets.dart';
import '../../generated/locales.g.dart';
import '../utils/common_utils.dart';
import 'msg_gift_loading.dart';

Widget get ex => const Spacer();

Widget get sh => const SizedBox.shrink();

extension Common on Comparable? {
  bool containsIgnoreCase(String other) {
    return val.toLowerCase().contains(other.toLowerCase());
  }

  String get val => this == null ? "" : toString();

  bool get isVoid => val.isEmpty;

  int get toInt => int.tryParse(val) ?? 0;

  Color hex([double alpha = 1]) {
    var hexStr = val.toUpperCase().replaceAll("#", "");
    int hex = int.parse(hexStr, radix: 16);
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO(
      (hex & 0xFF0000) >> 16,
      (hex & 0x00FF00) >> 8,
      (hex & 0x0000FF) >> 0,
      alpha,
    );
  }

  String get removeZeroWidthChars {
    // 零宽空格的Unicode码点：U+200B
    return val.replaceAll(RegExp('[\u200B]'), '');
  }

  Text tv({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      val.tr,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  Widget iv({
    double? width,
    double? height,
    Color? color,
    BoxFit? fit = BoxFit.cover,
    BlendMode? colorBlendMode,
  }) {
    if (val.isURL) {
      return CachedNetworkImage(
        imageUrl: val,
        width: width,
        height: height,
        fit: fit,
        color: color,
        placeholder: (context, url) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 30.w, maxHeight: 30.w),
            child: CircularProgressIndicator(strokeWidth: 2.w),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.image),
      );
    }
    return Image.asset(
      val,
      width: width,
      height: height,
      color: color,
      fit: fit,
      colorBlendMode: colorBlendMode,
    );
  }
}

int _lastClickTime = 0;

class TapBox extends GestureDetector {
  TapBox({
    super.key,
    Widget? child,
    EdgeInsetsGeometry? padding,
    int canClickDelay = 450,
    Function? onTap,
  }) : super(
         behavior: HitTestBehavior.translucent,
         onTap: onTap == null
             ? null
             : () {
                 var now = DateTime.now().millisecondsSinceEpoch;
                 if (now - _lastClickTime < canClickDelay) return;
                 _lastClickTime = now;
                 onTap.call();
               },
         child: padding != null
             ? Padding(padding: padding, child: child)
             : child,
       );
}

extension GetWidget on GetInterface {
  void dismissDialog() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void dismissBottomSheet() {
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  Future<void> popTo(
    String routeName, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    bool exists = false;

    Get.until((route) {
      exists = route.settings.name == routeName;
      return exists;
    });
    if (!exists) {
      Get.toNamed(
        routeName,
        arguments: arguments,
        id: id,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
      );
    }
  }
}

class SLoading extends StatelessWidget {
  const SLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      ),
    );
  }
}

extension GetWindow on GetInterface {
  void closeBottomSheet<T>({T? result}) {
    if (isBottomSheetOpen == true) {
      Get.back(result: result);
    }
  }

  void closeDialog() {
    if (isDialogOpen == true) {
      Get.back();
    }
  }
}

/// 构建富文本
List<InlineSpan> buildTextSpans({
  required String origin,
  required List<String> targets,
  TextStyle? style,
  required InlineSpan Function(String target, TextStyle? style, int index)
  buildTargetTextSpan,
}) {
  final spans = <InlineSpan>[];
  int lastIndex = 0;

  for (int i = 0; i < targets.length; i++) {
    final start = origin.indexOf(targets[i]);
    if (start == -1) continue; // 不存在就跳过
    if (start > lastIndex) {
      spans.add(
        TextSpan(text: origin.substring(lastIndex, start), style: style),
      );
    }
    spans.add(buildTargetTextSpan(targets[i], style, i));
    lastIndex = start + targets[i].length;
  }

  if (lastIndex < origin.length) {
    spans.add(TextSpan(text: origin.substring(lastIndex), style: style));
  }

  return spans;
}

void dismissAndShowMsg(String message) {
  SmartDialog.dismiss();
  SmartDialog.showToast(message);
}

Future showClothesLoading() {
  return SmartDialog.show(
    clickMaskDismiss: false,
    alignment: Alignment.bottomCenter,
    keepSingle: true,
    tag: "clothesLoading",
    builder: (BuildContext context) {
      return SizedBox(height: Get.height / 2.6, child: const MsgGiftLoading());
    },
  );
}

Future hiddenClothesLoading() {
  return SmartDialog.dismiss(tag: "clothesLoading");
}

Future<void> showEditContentSheet({
  String? defTxt,
  String? defHits,
  FocusNode? focusNode,
  FutureOr Function(String? txt)? onConfirm,
  bool onConfirmDismiss = true,
  String? title,
}) async {
  final TextEditingController textEditingController = TextEditingController(
    text: defTxt,
  );
  await Get.bottomSheet(
    SizedBox(
      width: double.infinity,
      height: 332.h,
      child: Stack(
        children: [
          Positioned(
            left: 16.w,
            top: 0,
            child: TapBox(onTap: Get.closeBottomSheet, child: buildCloseIcon()),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 44.h,
            child: Container(
              height: 280.h,
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.6],
                  colors: [Color(0xFFFFDFFD), Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.val,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.verticalSpace,
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 170.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            controller: textEditingController,
                            cursorColor: Colors.black,
                            maxLines: null,
                            expands: true,
                            maxLength: 500,
                            focusNode: focusNode,
                            autofocus: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                12.w,
                                10.h,
                                12.w,
                                10.h,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.30),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              hintText: defHits,
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _EditContentConfirmButton(
                            onTap: () async {
                              if (onConfirmDismiss) {
                                Get.closeBottomSheet();
                              }
                              await onConfirm?.call(textEditingController.text);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.68),
  );
  Future.delayed(Duration(milliseconds: 300), textEditingController.dispose);
}

class _EditContentConfirmButton extends StatelessWidget {
  const _EditContentConfirmButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: Container(
        width: 148.w,
        height: 32.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
          ),
        ),
        child: Text(
          LocaleKeys.done.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

Widget buildTheme2BottomBtn({
  Function? done,
  Function? cancel,
  String? doneTitle,
}) {
  return SafeArea(
    child: Row(
      children: [
        buildTheme3Btn(
          title: LocaleKeys.cancel.tr,
          onTap: cancel ?? Get.closeBottomSheet,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Color(0xff1C1A1D), width: 1),
          ),
        ),
        11.horizontalSpace,
        Expanded(
          flex: 2,
          child: buildTheme3Btn(
            alignment: Alignment.center,
            title: doneTitle ?? LocaleKeys.done.tr,
            onTap: done,
          ),
        ),
      ],
    ),
  );
}

Future<void> showHelpUs() {
  if ((Get.isDialogOpen ?? false) || (Get.isBottomSheetOpen ?? false)) {
    return Future.value();
  }
  final labels = [
    LocaleKeys.helpUsNotSatisfied,
    LocaleKeys.helpUsCouldBeBetter,
    LocaleKeys.helpUsLovingIt,
  ];
  var selectedIndex = -1;

  return Get.dialog<void>(
    Material(
      color: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            width: Get.width,
            height: Get.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.76),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  top: 161.h,
                  child: SizedBox(
                    width: 343.w,
                    height: 291.h,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Assets.imagesBgHelpUs.iv(
                            width: 343.w,
                            height: 291.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 122.h,
                          child: Text(
                            LocaleKeys.helpUsTitle.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20.w,
                          top: 165.h,
                          child: Row(
                            children: List.generate(labels.length, (index) {
                              final isSelected =
                                  selectedIndex >= 0 && selectedIndex >= index;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == labels.length - 1 ? 0 : 24.w,
                                ),
                                child: TapBox(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 84.w,
                                    height: 84.w,
                                    child: Center(
                                      child: _buildHelpUsStarIcon(isSelected),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 253.h,
                          child: SizedBox(
                            height: 15.h,
                            child: selectedIndex >= 0
                                ? Text(
                                    labels[selectedIndex].tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: (Get.width - 250.w) / 2,
                  top: 472.h,
                  child: TapBox(
                    onTap: selectedIndex < 0
                        ? null
                        : () {
                            if (selectedIndex != 2) {
                              toEmail();
                            } else {
                              openStoreReview();
                            }
                          },
                    child: Container(
                      width: 250.w,
                      height: 44.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedIndex < 0
                            ? const Color(0xFF4D2D4A)
                            : null,
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: selectedIndex < 0
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
                              ),
                      ),
                      child: Text(
                        LocaleKeys.submit.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedIndex < 0
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (Get.width - 24.w) / 2,
                  top: 536.h,
                  child: TapBox(
                    onTap: Get.closeDialog,
                    child: buildCloseIcon(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierColor: Colors.transparent,
    useSafeArea: false,
  );
}

Widget _buildHelpUsStarIcon(bool isSelected) {
  final star = Assets.imagesIcHelpUsStarOn.iv(
    width: 64.w,
    height: 64.w,
    fit: BoxFit.contain,
  );
  if (isSelected) return star;
  return Opacity(
    opacity: 0.56,
    child: ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: star,
    ),
  );
}

Widget buildProcessView() {
  return Positioned.fill(
    child: AbsorbPointer(
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 40.w),
              decoration: BoxDecoration(color: '#222222'.hex(0.6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.genHits.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ).marginSymmetric(horizontal: 16.w),
                  30.verticalSpace,
                  CircularProgressIndicator(
                    strokeWidth: 4.r,
                    color: cTheme.primary,
                  ),
                  20.verticalSpace,
                  Text(
                    LocaleKeys.aiCre.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
