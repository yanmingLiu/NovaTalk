import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/assets.dart';

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

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${(proText * 100).toInt()} ",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              Text(
                "/100",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          KanimGradProgress(
            width: 74,
            progress: progress,
            height: 4,
            borderRadius: 3,
            trackColor: Colors.white.withValues(alpha: 0.25),
            gradientColors: [Color(0xFFFF96F7), Color(0xFFFF96F7)],
            animationDuration: const Duration(milliseconds: 500),
          ),
          const SizedBox(width: 8),
          Assets.imagesIcGem.iv(width: 16),
          const SizedBox(width: 4),
          Text(
            rewards,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ],
      );
    });
  }
}
