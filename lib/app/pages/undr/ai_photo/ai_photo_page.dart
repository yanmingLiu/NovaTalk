import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';

import '../../../configs/app_theme.dart';
import '../undr_page.dart';
import '../undr_video.dart';
import 'ai_photo_controller.dart';
import 'ai_photo_design.dart';

class AiPhotoPage extends GetView<AiPhotoController> {
  const AiPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AiPhotoController());
    return ReleaseTextEditFocus(
      child: buildDefaultBg(
        bgColor: Colors.black,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiPhotoHomeHeader(),
              22.verticalSpace,
              Obx(
                () => AiPhotoModeTabs(
                  isImageSelected: controller.createImg.value,
                  onImageSelected: (isImageSelected) {
                    controller.createImg.value = isImageSelected;
                  },
                ),
              ),
              12.verticalSpace,
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.createImg.value ? 0 : 1,
                    children: [
                      UndressPage(tag: AiPhotoController.tag),
                      const UndrVideoPage(homeReuse: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
