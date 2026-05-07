import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../generated/assets.dart';
import '../../../configs/constans.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/gradient_bound_painter.dart';

class KGemBtn extends StatelessWidget {
  const KGemBtn({super.key, required this.from});

  final ConsumeFrom from;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final balance = AppUser.inst.balance.value;
      final text = '$balance';

      return GestureDetector(
        onTap: () {
          Get.toNamed(Routes.GEM, arguments: from);
        },
        child: CustomPaint(
          painter: GradientBoundPainter(
            radius: 4.r,
            strokeWidth: 1.w,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 4.h),
            child: Row(
              children: [
                Assets.imagesIcGem.iv(width: 16),
                const SizedBox(width: 4),
                text.tv(style: tTheme.titleLarge),
              ],
            ),
          ),
        ),
      );
    });
  }
}
