import 'dart:io';

import 'package:novatalk/app/configs/app_config.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/und_style_bean.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../../generated/locales.g.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common_widget.dart';
import 'ai_photo/ai_photo_design.dart';
import 'ctls/undress_page_controller.dart';

TextStyle undrDescribeTextStyle() => TextStyle(
  fontSize: 12.sp,
  color: Colors.white,
  fontWeight: FontWeight.w400,
);

TextStyle undrTitleTextStyle() => TextStyle(
  fontSize: 14.sp,
  fontWeight: FontWeight.w700,
  color: cTheme.primary,
);

class UndressPage extends StatelessWidget {
  final String? tag;

  UndressPage({super.key, this.tag});

  late final UndressPageController controller = Get.find<UndressPageController>(
    tag: tag,
  );

  @override
  Widget build(BuildContext context) {
    final body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        children: [
          if (!controller.args.isHomeReuse)
            SafeArea(
              bottom: false,
              child: AiPhotoStandaloneHeader(title: LocaleKeys.dress.tr),
            ),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
    return ReleaseTextEditFocus(
      child: controller.args.isHomeReuse
          ? body
          : buildDefaultBg(bgColor: Colors.black, child: body),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      final showStyle = controller.showStyle.value;
      final showBodyTitle = !showStyle && !controller.undressAnother.value;
      return Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: showStyle ? _selectedPhotoScrollPadding(context) : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBodyTitle) ...[
                  if (controller.args.isHomeReuse)
                    2.verticalSpace
                  else
                    18.verticalSpace,
                  buildAiPhotoBodyTitle(LocaleKeys.dress.tr),
                  15.verticalSpace,
                ],
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 52.w),
                  child: _buildImageCard(),
                ),
                showStyle ? 8.verticalSpace : 12.verticalSpace,
                if (showStyle)
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: undressTemplate(),
                  )
                else if (!controller.undressAnother.value)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 52.w),
                    child: buildAiPhotoHintList([
                      LocaleKeys.aHits1,
                      LocaleKeys.abHits2,
                      LocaleKeys.uHits3,
                      LocaleKeys.uHits4,
                    ]),
                  ),
                showStyle ? 80.verticalSpace : 150.verticalSpace,
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: showStyle
                ? AiPhotoBottomActionPanel(
                    homeReuse: controller.args.isHomeReuse,
                    child: _buildBottomAction(),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: aiPhotoBottomButtonOffset(
                        context: context,
                        homeReuse: controller.args.isHomeReuse,
                      ),
                    ),
                    child: Center(child: _buildBottomAction()),
                  ),
          ),
          if (controller.undressing.value) buildProcessView(),
        ],
      );
    });
  }

  double _selectedPhotoScrollPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + 140.h;
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 350.h,
      decoration: BoxDecoration(
        color: aiPhotoPanel,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: buildImage()),
            if (controller.showStyle.value || controller.undressAnother.value)
              Positioned(
                right: 10.w,
                top: 10.h,
                child: TapBox(
                  onTap: controller.resetState,
                  child: buildCloseIcon(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    if (controller.showStyle.value) {
      return buildAiPhotoGenerateAction(
        balance: AppUser.inst.createImg.value,
        unit: LocaleKeys.photos.tr,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.undressCharacter();
        },
      );
    }
    if (controller.undressAnother.value) {
      return buildAiPhotoActionButton(
        title: LocaleKeys.create.tr,
        onTap: controller.selectImage,
      );
    }
    if (controller.args.isHomeReuse) {
      return buildAiPhotoActionButton(
        title: LocaleKeys.uploadImage.tr,
        onTap: controller.selectImage,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildAiPhotoActionButton(
          title: LocaleKeys.uploadImage.tr,
          outlined: true,
          width: 150.w,
          onTap: controller.selectImage,
        ),
        12.horizontalSpace,
        Obx(
          () => buildAiPhotoActionButton(
            title: controller.finishGenerate.value
                ? LocaleKeys.viewCha.tr
                : LocaleKeys.uRole.tr,
            width: 150.w,
            onTap: controller.undressCharacter,
          ),
        ),
      ],
    );
  }

  Widget buildImage() {
    final uri = controller.userSelectedImage.value.isVoid
        ? AppConfig.undressBeforeImage
        : controller.userSelectedImage.value!;

    if (uri.isURL) {
      return TapBox(
        onTap: () {
          var url = controller.userSelectedImage.value;
          if (url.isVoid) return;
          Get.toNamed(Routes.IMAGEP_REVIEW, arguments: url);
        },
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator(color: cTheme.primary)),
          imageUrl: controller.userSelectedImage.value.isVoid
              ? AppConfig.undressBeforeImage
              : controller.userSelectedImage.value!,
        ),
      );
    }
    return Image.file(File(uri), fit: BoxFit.cover);
  }

  //模版
  Widget undressTemplate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${LocaleKeys.artStyle.tr}:",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        4.verticalSpace,
        Obx(
          () => SizedBox(
            height: 76.h,
            child: ListView.separated(
              itemCount: controller.templateConfigList.length,
              shrinkWrap: true,

              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 0),
              separatorBuilder: (context, index) => 0.horizontalSpace,
              itemBuilder: (context, index) {
                return Obx(() {
                  UndStyleBean data = controller.templateConfigList[index];
                  bool isSelected =
                      controller.undressSelectedIndex.value == index;
                  return TapBox(
                    onTap: () {
                      controller.selectUndressMode(index);
                    },
                    child: Container(
                      width: 64.w,
                      height: 76.h,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            padding: EdgeInsets.all(9.r),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? aiPhotoAccent.withValues(alpha: 0.10)
                                  : Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8.r),
                              border: isSelected
                                  ? Border.all(color: aiPhotoAccent, width: 1.r)
                                  : null,
                            ),
                            child: CachedNetworkImage(
                              width: 24.w,
                              height: 24.w,
                              imageUrl: data.icon ?? '',
                              color: isSelected ? aiPhotoAccent : Colors.white,
                              errorWidget: (context, url, error) {
                                return buildLoadingWidget();
                              },
                              placeholder: (context, url) {
                                return buildLoadingWidget();
                              },
                            ),
                          ),
                          4.verticalSpace,
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 58.w),
                            child: Text(
                              data.name ?? '',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isSelected
                                    ? aiPhotoAccent
                                    : Colors.white.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),
        8.verticalSpace,
        Text(
          "${LocaleKeys.cusPrompt.tr}:",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        5.verticalSpace,
        Builder(
          builder: (context) {
            final border = OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            );
            return InkWell(
              onTap: () {
                showCustomPromptDialog(context);
              },
              child: SizedBox(
                height: 48.h,
                child: TextField(
                  enabled: false,
                  cursorColor: Theme1.cursorColor,
                  controller: controller.customPromptController,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    hintText: LocaleKeys.promptHits2.tr,
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: .normal,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: border,
                    disabledBorder: border,
                    enabledBorder: border,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> showCustomPromptDialog(BuildContext context) async {
    String? oldValue = controller.customPromptController.text;
    await showEditContentSheet(
      defTxt: oldValue.val,
      title: "${LocaleKeys.cusPrompt.tr}:",
      defHits: LocaleKeys.promptHits2.tr,
      onConfirm: (v) {
        controller.customPromptController.text = v.val;
        controller.setCustomPrompt();
      },
    );
  }
}

Widget buildUndrBtn({
  EdgeInsetsGeometry? margin,
  String? title,
  bool tb1 = false,
  bool bold = false,
  double? vertical,
  Widget? titleWidget,
  onTap,
}) {
  return buildTheme3Btn(
    alignment: Alignment.center,
    onTap: onTap,
    title: title,
    vertical: vertical ?? 10.h,
    decoration: tb1
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              width: 1,
              color: Color(0xff1C1A1D).withValues(alpha: 0.5),
            ),
          )
        : null,
    titleWidget:
        titleWidget ??
        title.tv(
          style: bold
              ? TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                )
              : TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
        ),
  );
}

Widget buildLoadingWidget() {
  return Container(
    color: const Color(0x33906BF7),
    child: const Center(child: Icon(Icons.image, color: Color(0x80808080))),
  );
}
