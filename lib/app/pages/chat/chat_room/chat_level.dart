import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../generated/assets.dart';
import '../../../configs/app_theme.dart';
import '../../../widgets/gradient_bound_painter.dart';
import 'k_anim_grad_progress.dart';

class ChatLevel extends StatelessWidget {
  const ChatLevel({super.key});

  String formatNumber(double? value) {
    if (value == null) {
      return '0';
    }
    if (value % 1 == 0) {
      // 如果小数部分为 0，返回整数
      return value.toInt().toString();
    } else {
      // 如果有小数部分，返回原值
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<ChatRoomController>();
    return Obx(() {
      final data = ctr.chatLevel.value;
      if (data == null) {
        return const SizedBox();
      }

      var level = data.level ?? 1;
      var progress = (data.progress ?? 0) / 100.0;
      var rewards = '+${data.rewards ?? 0}';

      var total = data.upgradeRequirements?.toInt() ?? 0;
      double proText = (data.progress ?? 0) / total;

      return SizedBox(
        width:  Get.width/2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline:  TextBaseline.alphabetic,
              children: [
                Text(
                  'Lv',
                  style: tTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                5.horizontalSpace,
                Text(
                  '$level',
                  style: tTheme.bodyLarge,
                ),
                5.horizontalSpace,

                Text(
                  "${(proText * 100).toInt()} ",
                  style: tTheme.labelSmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffF6E961),
                  ),
                ),
                Text(
                  "/100",
                  style: tTheme.labelSmall?.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ex,
                Assets.imagesIcGem.iv(width: 15.w).paddingOnly(top: 3.h),
                const SizedBox(width: 4),
                Text(
                  rewards,
                  style: tTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                  // style: GoogleFonts.montserrat(
                  //   color:  cTheme.shadow,
                  //   fontSize: 13.sp,
                  //   fontWeight: FontWeight.w700,
                  //   fontStyle: FontStyle.italic,
                  //   shadows: [
                  //     Shadow(
                  //       color: "#8C5AFF".hex(),
                  //       offset: Offset(1, 1),
                  //       blurRadius: 5,
                  //     ),
                  //   ],
                  // ),
                ),
              ],
            ),
            5.verticalSpace,
            KanimGradProgress(
              width:  Get.width/2,
              progress: progress,
              height: 4,
              borderRadius: 3,
              trackColor: Colors.white.withValues(alpha: 0.25),
              gradientColors: [Color(0xffB0ECFD), Color(0xff78D5FA)],
              animationDuration: const Duration(milliseconds: 500),
            ),
          ],
        ),
      );
    });
  }
}
