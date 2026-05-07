import 'dart:ui';

import 'package:novatalk/app/pages/chat/chat_room/chat_level.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../generated/assets.dart';
import '../../../entities/role_entity.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/log/log_event.dart';

class RoleImages extends StatefulWidget {
  const RoleImages({super.key});

  @override
  State<RoleImages> createState() => _RoleImagesState();
}

class _RoleImagesState extends State<RoleImages> {
  final imageHeight = 64.0;
  bool _isExpanded = true;

  final ctr = Get.find<ChatRoomController>();

  final images = <RoleRecordsImages>[].obs;

  @override
  void initState() {
    super.initState();

    images.value = ctr.role.images ?? [];

    ever(ctr.roleImagesChanged, (_) {
      images.value = ctr.role.images ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      images.value;
      return  _buildImages();
    });
  }

  Widget _buildImages() {
    final imageCount = images.length;

    bool showImages = imageCount > 0 && CloUtil.isCloB;

    bool canVideoChat = CloUtil.isCloB && ctr.role.videoChat == true;
    final guide = ctr.role.characterVideoChat?.firstWhereOrNull(
      (e) => e.tag == 'guide',
    );
    final url = guide?.gifUrl ?? ctr.role.avatar;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TapBox(
                    //   onTap:  () {
                    //     if(!canVideoChat)return;
                    //     logEvent('c_videocall');
                    //     pushPhone(
                    //       sessionId: ctr.session.id.toInt,
                    //       role: ctr.role,
                    //       showVideo: true,
                    //     );
                    //   },
                    //   child: Stack(
                    //     alignment:  Alignment.bottomCenter,
                    //     children: [
                    //       ClipOval(
                    //         child: url.iv(width: 52.w, height: 52.w),
                    //       ),
                    //       if (canVideoChat)
                    //         Positioned(
                    //           bottom: 0,
                    //           child: Assets.imagesIgChatCall.iv(width: 18.w),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    ChatLevel(),

                    if (_isExpanded && showImages)
                    ex,
                    if (showImages)
                      TapBox(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          height: 39.h,
                          width: 30.w,
                          alignment:  Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: RotatedBox(
                            quarterTurns: _isExpanded ? 2 : 0,
                            child: Assets.imagesPhNext.iv(width: 10.w),
                          ),
                        ),
                      ).marginOnly(left: 10.w),
                  ],
                ),
                if (showImages)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // 动画持续时间
                    curve: Curves.easeInOut,
                    // 动画曲线
                    margin: EdgeInsets.only(
                      top: _isExpanded ? 18.h : 0,
                      bottom: _isExpanded ? 12.h : 0,
                    ),
                    height: _isExpanded ? 64 : 0,
                    width: _isExpanded ? Get.width : 0,
                    // 根据状态动态调整高度
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, idx) {
                        final image = images[idx];
                        final unlocked = image.unlocked ?? false;
                        return ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          child: Container(
                            height: imageHeight,
                            width: imageHeight,
                            color: const Color(0x4D333333),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      ctr.onTapImage(image);
                                    },
                                    child: image.imageUrl.iv(),
                                  ),
                                ),
                                if (!unlocked)
                                  GestureDetector(
                                    onTap: () {
                                      ctr.onTapUnlockImage(image);
                                    },
                                    child: Stack(
                                      children: [
                                        BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 7,
                                            sigmaY: 7,
                                          ),
                                          child: Container(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Assets.imagesIcGem.iv(
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  Text(
                                                    '${image.gems ?? 0}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 12);
                      },
                      itemCount: imageCount,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
