import 'dart:math';

import 'package:novatalk/app/pages/chat/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../generated/assets.dart';
import '../../configs/constans.dart';
import '../../routes/app_pages.dart';
import 'setting_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingView extends GetBuildView<SettingController> {
  const SettingView({super.key});

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Assets.imagesBgkSetting.iv(fit: BoxFit.fitWidth),
          Column(
            children: [
              buildHomeAppBar(
                width: 102.w,
                leading: sh,
                actions: [
                  buildGemWidget().marginOnly(right: 12.w),
                  TapBox(
                    onTap: () {
                      Get.toNamed(Routes.CHOOSE_LANG);
                    },
                    child: Assets.imagesPhAiLang.iv(width: 28.w),
                  ),
                  12.horizontalSpace,
                ],
              ),
              55.verticalSpace,
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          topVIPWidget(),
                          20.verticalSpace,
                          Expanded(
                            child: Obx(() {
                              final menuList = [
                                (
                                  controller.chatBgImagePath.value.isNotEmpty
                                      ? LocaleKeys.restore.tr
                                      : LocaleKeys.wallpaper.tr,
                                  Assets.imagesPhSetChatbg,
                                  () {
                                    if (controller
                                        .chatBgImagePath
                                        .value
                                        .isNotEmpty) {
                                      controller.resetChatBackground();
                                    } else {
                                      controller.changeChatBackground();
                                    }
                                  },
                                ),
                                (
                                  LocaleKeys.shareFeedback.tr,
                                  Assets.imagesPhSetFb,
                                  () {
                                    toEmail();
                                  },
                                ),
                                (
                                  LocaleKeys.policy.tr,
                                  Assets.imagesPhSetPolicy,
                                  () {
                                    toPrivacy();
                                  },
                                ),
                                (
                                  LocaleKeys.terms.tr,
                                  Assets.imagesPhSetTerms,
                                  () {
                                    toTerms();
                                  },
                                ),
                              ];

                              return GridView.builder(
                                itemCount: menuList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 12.w,
                                      childAspectRatio: 1.63,
                                    ),
                                itemBuilder: (context, index) {
                                  return buildMenuItem(menuList[index]);
                                },
                              );
                            }),
                          ),
                          // Expanded(
                          //   child: Container(
                          //     margin: const EdgeInsets.only(top: 20),
                          //     child: SingleChildScrollView(
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           buildGroup(
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 TabTitle(
                          //                   title: LocaleKeys.support.tr,
                          //                 ),
                          //                 TabItem(
                          //                   title: LocaleKeys.languageHits.tr,
                          //                   onTap: () {
                          //                     Get.toNamed(Routes.CHOOSE_LANG);
                          //                   },
                          //                   subtitle: Obx(
                          //                     () => Container(
                          //                       alignment: .centerRight,
                          //                       width: Get.width / 2,
                          //                       child:
                          //                           Text(
                          //                             AppUser
                          //                                     .inst
                          //                                     .targetLanguage
                          //                                     .value
                          //                                     .label ??
                          //                                 "",
                          //                             maxLines: 1,
                          //                             overflow:
                          //                                 TextOverflow.ellipsis,
                          //                             style: const TextStyle(
                          //                               fontSize: 14,
                          //                               color: Colors.white,
                          //                               fontWeight:
                          //                                   FontWeight.w400,
                          //                             ),
                          //                           ).marginSymmetric(
                          //                             horizontal: 8.w,
                          //                           ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 TabItem(
                          //                   title: LocaleKeys.shareFeedback.tr,
                          //                   onTap: () {
                          //                     toEmail();
                          //                   },
                          //                 ),
                          //                 Obx(
                          //                   () => TabItem(
                          //                     title:
                          //                         controller
                          //                             .chatBgImagePath
                          //                             .value
                          //                             .isNotEmpty
                          //                         ? LocaleKeys.restore.tr
                          //                         : LocaleKeys.wallpaper.tr,
                          //                     onTap: () {
                          //                       if (controller
                          //                           .chatBgImagePath
                          //                           .value
                          //                           .isNotEmpty) {
                          //                         controller
                          //                             .resetChatBackground();
                          //                       } else {
                          //                         controller
                          //                             .changeChatBackground();
                          //                       }
                          //                     },
                          //                   ),
                          //                 ),
                          //
                          //                 // MeItem(
                          //                 //   title: LocaleKeys.app_version.tr,
                          //                 //   subtitle: Text(
                          //                 //     _version,
                          //                 //     style: GoogleFonts.montserrat(
                          //                 //       fontSize: 14,
                          //                 //       color: Colors.white,
                          //                 //     ),
                          //                 //   ),
                          //                 // ),
                          //               ],
                          //             ),
                          //           ),
                          //           buildGroup(
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 TabTitle(title: LocaleKeys.legal.tr),
                          //                 TabItem(
                          //                   title: LocaleKeys.policy.tr,
                          //                   onTap: () {
                          //                     toPrivacy();
                          //                   },
                          //                 ),
                          //                 TabItem(
                          //                   title: LocaleKeys.service.tr,
                          //                   onTap: () {
                          //                     toTerms();
                          //                   },
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ).marginOnly(top: 65.h),
                      Positioned(top: -17.h, child: buildUserInfo()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem((String, String, Function) record) {
    return TapBox(
      onTap: record.$3,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xff979797).withValues(alpha: 0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            record.$2.iv(width: 24.w),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 100.w,
              ),
              child: record.$1
                  .tv(style: tTheme.bodyLarge!.copyWith(color: Color(0xff434343)),textAlign:  TextAlign.center)
                  .marginOnly(top: 12.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGroup({required Widget child}) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 3.h),
      margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  Widget topVIPWidget() {
    return Obx(() {
      var isVip = AppUser.inst.isVip.value;
      if (isVip) {
        final timer =
            AppUser.inst.user?.subscriptionEnd ??
            DateTime.now().millisecondsSinceEpoch;
        final date = formatTimestamp(timer);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16.w,
                vertical: 24.h,
              ),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(Assets.imagesBgkSetVip),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocaleKeys.vipSubscriber.tv(
                    style: tTheme.displaySmall!.copyWith(
                      color: Colors.white,
                      fontSize: 21.sp,
                    ),
                  ),
                  5.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LocaleKeys.validTime
                          .trParams({"1": ""})
                          .tv(
                            style: tTheme.bodyLarge!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                      date
                          .tv(
                            style: tTheme.bodyLarge!.copyWith(
                              color: cTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .marginOnly(top: 2.h),
                    ],
                  ),
                ],
              ).marginOnly(left: 15.w),
            ),
          ],
        ).marginSymmetric(horizontal: 16.w);
      }
      return TapBox(
        onTap: () {
          Get.toNamed(Routes.VIP, arguments: VipFrom.mevip);
        },
        child: Container(
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(maxHeight: 104.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            image: const DecorationImage(
              image: AssetImage(Assets.imagesBgkSetVip),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: buildTextSpans(
                        origin: LocaleKeys.goVip.tr,
                        targets: ["VIP"],
                        style: tTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontSize: 21.sp,
                        ),
                        buildTargetTextSpan: (text, style, index) {
                          return TextSpan(
                            text: text,
                            style: style?.copyWith(color: cTheme.scrim),
                          );
                        },
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Transform.rotate(
                    angle: 180 * pi / 95,
                    child: Assets.imagesIcVip.iv(width: 32.w),
                  ),
                ],
              ),
              4.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LocaleKeys.benefitsVip.tv(
                    style: tTheme.bodyLarge!.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  ex,
                  Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: cTheme.primary, width: 1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: LocaleKeys.upgrade.tv(
                      style: tTheme.bodyLarge!.copyWith(color: cTheme.scrim),
                    ),
                  ),
                ],
              ),
            ],
          ).marginOnly(left: 24.w, right: 20.w),
        ),
      ).marginSymmetric(horizontal: 12.w);
    });
  }

  Widget buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentGeometry.bottomRight,
          children: [
            Assets.imagesPhUserAvatar.iv(width: 60.w),
            if (AppUser.inst.isVip.value)
              buildLikeThemeBtn(
                padding: EdgeInsets.all(3.r),
                shape: BoxShape.circle,
                contentWidget: Assets.imagesIcVip.iv(width: 14.w),
              ),
          ],
        ),
        20.horizontalSpace,
        TapBox(
          onTap: () async {
            final nicknameController = TextEditingController();

            await Get.bottomSheet(
              buildTheme2SheetRootWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocaleKeys.yourNickname.tv(
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    16.verticalSpace,
                    Container(
                      height: 42.h,
                      constraints: BoxConstraints(minHeight: 120.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: cTheme.scrim, width: 1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xffFFFBD8),
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: TextField(
                        maxLines: 1,
                        autofocus: true,
                        controller: nicknameController,
                        style: tTheme.bodyLarge!.copyWith(color: Colors.black),
                        decoration: InputDecoration(
                          hintText:
                              AppUser.inst.user?.nickname ??
                              LocaleKeys.screenName.tr,
                          hintStyle: tTheme.bodyLarge!.copyWith(
                            color: Color(0xff1C1A1D).withValues(alpha: 0.25),
                          ),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                        ),
                      ),
                    ),
                    12.verticalSpace,
                    SafeArea(
                      child: Row(
                        children: [
                          buildTheme3Btn(
                            title: LocaleKeys.cancel.tr,
                            onTap: () => Get.closeBottomSheet(),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: Color(0xff1C1A1D),
                                width: 1,
                              ),
                            ),
                          ),
                          11.horizontalSpace,
                          Expanded(
                            flex: 2,
                            child: buildTheme3Btn(
                              alignment: Alignment.center,
                              title: LocaleKeys.done.tr,
                              onTap: () async {
                                var newNickname = nicknameController.text
                                    .trim();
                                if (newNickname.isEmpty) {
                                  SmartDialog.showToast(
                                    LocaleKeys.nameEmpty.tr,
                                  );
                                  return;
                                }
                                Get.closeBottomSheet();
                                controller.changeNickName(newNickname);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 12.w, vertical: 16.h),
              ),
              isScrollControlled: false,
            );
          },
          child: Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Get.width / 1.8),
                  child: (AppUser.inst.nickname.value).tv(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tTheme.displaySmall!.copyWith(color: Colors.black),
                  ),
                ),
                Assets.imagesPhPen
                    .iv(width: 16.w)
                    .marginOnly(left: 8.w, bottom: 5.h),
              ],
            ),
          ),
        ),
      ],
    ).marginSymmetric(horizontal: 20.w);
  }
}

class TabTitle extends StatelessWidget {
  const TabTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: tTheme.bodyLarge!.copyWith(
          color: Colors.black.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.showNext = true,
    this.subtitle,
  });

  final String title;
  final String? icon;
  final Widget? subtitle;
  final Function()? onTap;
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Row(
              children: [
                if (icon != null) icon.iv(width: 24.w).marginOnly(right: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: tTheme.bodyLarge!.copyWith(
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                if (subtitle != null) subtitle!,
                if (showNext)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                    child: Assets.imagesPhBack.iv(
                      width: 24.r,
                      color: Color(0xff746B49),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color thumbColor;
  final Color trackColor;
  final List<Color> colors;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = const Color(0xFF646BFF),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.trackColor = const Color(0xFFB3B3B3),
    this.colors = const [],
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    bool value = widget.value; // 直接使用传入的 value 控制外观

    return GestureDetector(
      onTap: () {
        setState(() {
          value = !value;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
      child: Container(
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: value ? Colors.white : widget.trackColor,
          gradient: value
              ? LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? (36 - 16 - 2) : 2,
              right: value ? 2 : (36 - 16 - 2),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.thumbColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showEditDialog({
  String? title,
  Function(String)? onConfirm,
  String? hintText,
  int? maxLength,
  String? confirmText,
}) async {
  final TextEditingController controller = TextEditingController();
  await Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      ),
      child: buildDefaultBg(
        isExtend: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Get.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  title
                      .tv(
                        style: tTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                        ),
                      )
                      .paddingSymmetric(vertical: 20.h),
                  Positioned(
                    right: 12.w,
                    top: 12.h,
                    child: TapBox(
                      onTap: () {
                        Get.closeBottomSheet();
                      },
                      child: buildCloseIcon(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  24.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    margin: EdgeInsets.symmetric(horizontal: 60.w),
                    decoration: BoxDecoration(
                      color: cTheme.shadow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: TextField(
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        onSubmitted: (value) {
                          onConfirm?.call(value);
                        },
                        minLines: 1,
                        maxLength: maxLength ?? 20,
                        style: tTheme.titleSmall!.copyWith(color: Colors.black),
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: hintText,
                          counterText: '',
                          // 去掉字数显示
                          hintStyle: tTheme.titleSmall!.copyWith(
                            color: cTheme.shadow,
                          ),
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          filled: true,
                          isDense: true,
                        ),
                        focusNode: FocusNode()..requestFocus(),
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  TapBox(
                    onTap: () {
                      onConfirm?.call(controller.text);
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 65.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: cTheme.primary,
                      ),
                      child: (confirmText ?? LocaleKeys.confirmSel.tr).tv(
                        style: tTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  50.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
  Future.delayed(100.milliseconds, controller.dispose);
}


