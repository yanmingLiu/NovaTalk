import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_level.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../generated/assets.dart';
import '../../../../generated/locales.g.dart';
import '../../../configs/constans.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_user.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/log/log_event.dart';

class MsgAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MsgAppBar({super.key, required this.role, required this.ctr});

  final RoleRecords role;
  final ChatRoomController ctr;

  // 通过 preferredSize 确保 AppBar 的高度符合标准
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      scrolledUnderElevation: 0.0,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 0,
      leading: SizedBox.shrink(),
      title: Row(
        crossAxisAlignment: .center,
        spacing: 8,
        children: [
          SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(36.r),
            child: Stack(
              children: [
                role.avatar.iv(fit: .cover, width: 36, height: 36),
                Obx(() {
                  final data = ctr.chatLevel.value;
                  if (data == null) {
                    return const SizedBox();
                  }

                  var level = data.level ?? 1;
                  return Container(
                    color: Color(0x66000000),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2,
                      children: [
                        Text(
                          'Lvl $level',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF96F7),
                          ),
                        ),
                        if (role.videoChat == true)
                          Assets.imagesIcVideo.iv(height: 16),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.ROLE_PROFILE, arguments: role);
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          role.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!role.age.isVoid)
                        Container(
                          margin: EdgeInsets.only(left: 4.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
                            ),
                          ),
                          child: role.age.tv(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                ChatLevel(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TapBox(
          onTap: () {
            showChatLevel();
          },
          child: Assets.imagesPhGoodMood.iv(height: 24.h),
        ).marginOnly(right: 16.w),
        TapBox(
          onTap: () {
            logEvent('c_call');
            if (!AppUser.inst.isVip.value) {
              pushVip(VipFrom.call);
              return;
            }

            if (!AppUser.inst.isBalanceEnough(ConsumeFrom.call)) {
              pushGem(ConsumeFrom.call);
              return;
            }

            final sessionId = ctr.session.id;
            if (sessionId == null) {
              return;
            }
            pushPhone(sessionId: sessionId.toInt, role: role, showVideo: false);
          },
          child: Assets.imagesPhCall.iv(height: 24.h),
        ).marginOnly(right: 12.w),
        TapBox(
          onTap: () => Get.back(),
          child: Assets.imagesIcCloseOri.iv(height: 24.h),
        ).marginOnly(right: 16.w),
      ],
    );
  }

  void showChatLevel() {
    Widget buildTips({
      required int level,
      required int gemNum,
      required String icon,
      required Color bgColor,
    }) {
      return Container(
        width: double.infinity,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon.tv(
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            5.verticalSpace,
            LocaleKeys.level
                .trParams({"n": "$level"})
                .tv(
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
            5.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.imagesIcGem.iv(width: 20.w),
                4.horizontalSpace,
                "+$gemNum".tv(
                  style: tTheme.bodyLarge!.copyWith(
                    color: Color(0xff262626),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final tips = [
      (
        level: 1,
        gemNum: 10,
        icon: '👋',
        bgColor: Color(0xffFBF05D).withValues(alpha: 0.1),
      ),
      (
        level: 2,
        gemNum: 20,
        icon: '🥱',
        bgColor: Color(0xffFBF05D).withValues(alpha: 0.2),
      ),
      (
        level: 3,
        gemNum: 30,
        icon: '😊',
        bgColor: Color(0xffFBF05D).withValues(alpha: 0.3),
      ),
      (
        level: 4,
        gemNum: 40,
        icon: '💓',
        bgColor: Color(0xffFBF05D).withValues(alpha: 0.4),
      ),
    ];
    // Theme1Dialog.showGroup(
    //   child: Column(
    //     children: [
    //       LocaleKeys.upLevel.tv(style: tTheme.headlineMedium),
    //       20.verticalSpace,
    //       ListView.separated(
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         itemBuilder: (context, index) {
    //           final item = tips[index];
    //           return buildTips(
    //             level: item.level,
    //             gemNum: item.gemNum,
    //             icon: item.icon,
    //           );
    //         },
    //         itemCount: 4,
    //         separatorBuilder: (BuildContext context, int index) {
    //           return 9.verticalSpace;
    //         },
    //       ),
    //       14.verticalSpace,
    //     ],
    //   ).paddingSymmetric(horizontal: 16.w, vertical: 20.h),
    // );
    showTheme1Sheet(
      showCancel: false,
      child: Column(
        children: [
          LocaleKeys.upLevel
              .tv(
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              )
              .marginSymmetric(vertical: 16.h),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 9.w,
              crossAxisSpacing: 9.h,
            ),
            itemBuilder: (context, index) {
              final item = tips[index];
              return buildTips(
                level: item.level,
                gemNum: item.gemNum,
                icon: item.icon,
                bgColor: item.bgColor,
              );
            },
            itemCount: 4,
          ),
        ],
      ),
    );
  }
}
