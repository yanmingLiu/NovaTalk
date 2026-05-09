import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import 'creations_controller.dart';

class CreationsView extends GetBuildView<CreationsController> {
  const CreationsView({super.key});

  @override
  Widget builder(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SafeArea(bottom: false, child: _buildHeader()),
            16.verticalSpace,
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: MediaQuery.paddingOf(context).bottom + 16.h,
                ),
                itemCount: controller.creations.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 7.w,
                  mainAxisSpacing: 7.h,
                  childAspectRatio: 168 / 224,
                ),
                itemBuilder: (context, index) {
                  final item = controller.creations[index];
                  return TapBox(
                    onTap: () {
                      Get.toNamed(
                        Routes.IMAGEP_REVIEW,
                        arguments: item.resultUrl,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: item.resultUrl.iv(
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 35.h,
      width:  Get.width,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 11.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: TapBox(
                onTap: Get.back,
                child: buildBackIcon(color: Colors.white),
              ),
            ),
            LocaleKeys.creations.tr.tv(
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
