import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../generated/locales.g.dart';
import '../../configs/app_config.dart';
import '../../configs/app_theme.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_user.dart';
import '../../widgets/common_widget.dart';
import 'ai_photo/ai_photo_design.dart';
import 'ctls/undrvideo_page_controller.dart';

class UndrVideoPage extends GetView<UndrVideoPageController> {
  const UndrVideoPage({super.key, this.homeReuse = false});

  final bool homeReuse;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UndrVideoPageController>()) {
      Get.put(UndrVideoPageController());
    }
    final body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        children: [
          if (!homeReuse)
            SafeArea(
              bottom: false,
              child: AiPhotoStandaloneHeader(title: LocaleKeys.iToVideo.tr),
            ),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
    return homeReuse
        ? body
        : buildDefaultBg(bgColor: Colors.black, child: body);
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      final showPrompt = controller.showPrompt.value;
      return Stack(
        children: [
          SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showPrompt||controller.undressAnother.value) ...[
                  if (!homeReuse) 18.verticalSpace,
                ] else ...[
                  if (homeReuse) 2.verticalSpace else 18.verticalSpace,
                  buildAiPhotoBodyTitle(
                    LocaleKeys.aiVHits4.trParams({'s': AppConfig.kNS}),
                  ),
                  15.verticalSpace,
                ],
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 52.w),
                  child: Container(
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
                          if (showPrompt ||
                              (controller.undressAnother.value &&
                                  !controller.videoLoading.value))
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
                  ),
                ),
                12.verticalSpace,
                if (showPrompt)
                  showPromptView()
                else if (!controller.undressAnother.value)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 52.w),
                    child: buildAiPhotoHintList([
                      LocaleKeys.aiVHits1,
                      LocaleKeys.aiVHits2,
                      LocaleKeys.aiVHits3,
                    ]),
                  ),
                150.verticalSpace,
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: showPrompt
                ? AiPhotoBottomActionPanel(
                    homeReuse: homeReuse,
                    child: _buildBottomAction(),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: aiPhotoBottomButtonOffset(
                        context: context,
                        homeReuse: homeReuse,
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

  Widget _buildBottomAction() {
    if (controller.showPrompt.value) {
      return Obx(
        () => buildAiPhotoGenerateAction(
          balance: AppUser.inst.createVideo.value,
          unit: LocaleKeys.videoChat.tr,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            controller.undressVideo();
          },
        ),
      );
    }
    if (controller.undressAnother.value) {
      return buildAiPhotoActionButton(
        title: LocaleKeys.create.tr,
        onTap: controller.selectImage,
      );
    }
    return buildAiPhotoActionButton(
      title: LocaleKeys.uploadImage.tr,
      onTap: controller.selectImage,
    );
  }

  Widget buildImage() {
    return AspectRatio(
      aspectRatio: 0.77,
      child: Obx(() {
        var videoCtrl = controller.videoController.value;
        if (!controller.userSelectedImage.value.isVoid &&
            !controller.finishGenerate.value) {
          return Image.file(
            File(controller.userSelectedImage.value!),
            fit: BoxFit.cover,
          );
        }
        if (videoCtrl != null) {
          return TapBox(
            onTap: () async {
              if (videoCtrl.value.isInitialized) {
                Get.toNamed(
                  Routes.VIDEO_REVIEW,
                  arguments: controller.lastGenVideoUrl,
                );
                controller.videoController.value!.play();
              }
            },
            child: Stack(
              children: [
                VideoPlayer(controller.videoController.value!),
                controller.videoLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3.w,
                          color: cTheme.scrim,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget showPromptView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${LocaleKeys.prompt.tr}:",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.verticalSpace,
          SizedBox(
            height: 48.h,
            child: TextField(
              focusNode: controller.customPromptFocusNode,
              controller: controller.customPromptController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              maxLines: 1,
              maxLength: 500,
              cursorColor: Theme1.cursorColor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.30),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.10),
                counterText: '',
                hintText: LocaleKeys.videoPromptHits.tr,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
