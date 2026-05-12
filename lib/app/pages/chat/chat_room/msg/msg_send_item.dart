import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/widgets/blur_background.dart';

import '../../../../configs/app_theme.dart';
import '../../../../entities/msg_res.dart';

class MsgSendItem extends StatelessWidget {
  const MsgSendItem({super.key, required this.msg, required this.ctr});

  final isSend = false;
  final Msg msg;
  final ChatRoomController ctr;

  @override
  Widget build(BuildContext context) {
    final sendText = msg.question;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(maxWidth: Get.width * 0.8),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDFFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sendText ?? '',
                      style: tTheme.bodyLarge?.copyWith(
                        color: Color(0xff1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (msg.onAnswer == true)
          Row(
            children: [
              SBlurBackground(
                blur: 50,
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
                child: SizedBox(
                  width: 60.w,
                  child: Center(
                    child: LoadingAnimationWidget.progressiveDots(
                      color: Colors.white,
                      size: 35.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
