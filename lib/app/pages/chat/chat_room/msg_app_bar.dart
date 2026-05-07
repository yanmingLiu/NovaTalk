import 'package:novatalk/app/utils/clo_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../generated/assets.dart';
import '../../../../generated/locales.g.dart';
import '../../../configs/constans.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_user.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/log/log_event.dart';
import 'chat_level.dart';
import 'chat_room_view.dart';
import 'k_gem_btn.dart';

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
      leadingWidth: 35.w,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: TapBox(
          onTap: () {
            Get.back();
          },
          child: buildBackIcon(),
        ).marginOnly(left: 12.w),
      ),
      title: TapBox(
        onTap: () {
          Get.toNamed(Routes.ROLE_PROFILE, arguments: role);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            8.horizontalSpace,
            if (role.avatar != null)
              SizedBox.square(
                dimension: 36.r,
                child: ClipOval(child: role.avatar.iv()),
              ).marginOnly(right: 8.w),
            Flexible(
              child: Text(
                role.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tTheme.titleLarge,
              ),
            ),
            if (role.age != null)
              Container(
                margin: EdgeInsets.only(left: 12.w,right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Text(
                  '${role.age}',
                  style: tTheme.labelMedium?.copyWith(color: cTheme.primary),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TapBox(
          onTap: () {
            showChatLevel();
          },
          child: Assets.imagesPhGoodMood.iv(height: 28.h),
        ).marginOnly(right: 16.w),
        // if (CloUtil.isCloB)
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
              pushPhone(
                sessionId: sessionId.toInt,
                role: role,
                showVideo: false,
              );
            },
            child: Assets.imagesPhCall.iv(height: 28.h),
          ).marginOnly(right: 12.w),
        // const KGemBtn(from: ConsumeFrom.chat),
        // 14.horizontalSpace
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
          color:bgColor,
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
                .tv(style: TextStyle(fontSize: 14.sp,fontWeight:  FontWeight.w400,color:  Colors.black)),
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
      (level: 1, gemNum: 10, icon: '👋',bgColor:Color(0xffFBF05D).withValues(alpha: 0.1)),
      (level: 2, gemNum: 20, icon: '🥱', bgColor:Color(0xffFBF05D).withValues(alpha: 0.2)),
      (level: 3, gemNum: 30, icon: '😊', bgColor:Color(0xffFBF05D).withValues(alpha: 0.3)),
      (level: 4, gemNum: 40, icon: '💓',bgColor:Color(0xffFBF05D).withValues(alpha: 0.4)),
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
          LocaleKeys.upLevel.tv(
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500,
              color: Colors.black,),
          ).marginSymmetric(vertical: 16.h),
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
