import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/utils/storage_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import 'chat_float_items.dart';
import 'chat_room_controller.dart';
import 'msg_app_bar.dart';
import 'msg_input.dart';
import 'msg_list_view.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final role = controller.role;

    double bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    var msgBottom = 4 + bottomPadding + 48 + 12 + 26 + 4;

    return Stack(
      children: [
        StorageUtils.chatBgImagePath.isNotEmpty
            ? Positioned.fill(
                child: Image.file(
                  File(StorageUtils.chatBgImagePath),
                  fit: BoxFit.cover,
                ),
              )
            : Positioned.fill(child: role.avatar.iv()),

        Scaffold(
          appBar: MsgAppBar(role: role, ctr: controller),
          extendBodyBehindAppBar: true,
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                bottom: msgBottom,
                top: 50.h,
                child: MsgListView(role: role, ctr: controller),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(() {
                  return MsgInput(
                    ctr: controller,
                    inputTags: controller.inputTags.toList(),
                  );
                }),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: kMinInteractiveDimension + 6.h,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                12.verticalSpace,
                // const RoleImages(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (CloUtil.isCloB)
                        ChatMsgFloatItems(
                          role: role,
                          sessionId: controller.session.id.val,
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
