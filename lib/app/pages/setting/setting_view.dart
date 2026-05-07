import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/configs/constans.dart';
import 'package:novatalk/app/routes/app_pages.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/home_top_entries.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/generated/assets.dart';
import 'package:novatalk/generated/locales.g.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'setting_controller.dart';

class SettingView extends GetBuildView<SettingController> {
  const SettingView({super.key});

  static const _accent = Color(0xFFFF96F7);
  static const _accentLight = Color(0xFFFFDFFD);
  static const _panelColor = Color(0x1AFFFFFF);

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          buildDefaultBg(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 118.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  20.verticalSpace,
                  _buildUserInfo(),
                  20.verticalSpace,
                  _buildVipCard(),
                  16.verticalSpace,
                  _buildMenuPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 7.h),
      child: Row(
        children: [
          const HomeGemPill(),
          20.horizontalSpace,
          Obx(
            () => AppUser.inst.isVip.value
                ? sh
                : TapBox(
                    onTap: () {
                      pushVip(VipFrom.homevip);
                    },
                    child: const HomeVipEntry(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return TapBox(
      onTap: _showEditNicknameSheet,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 92.w,
                height: 92.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Image.asset(
                    Assets.imagesIcMeAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Assets.imagesPhUserAvatar.iv(fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                bottom: 2.h,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Assets.imagesIcMeEdit.iv(width: 20.w, height: 20.w),
                ),
              ),
            ],
          ),
          16.verticalSpace,
          Obx(
            () => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 260.w),
              child:
                  (AppUser.inst.nickname.value.isEmpty
                          ? LocaleKeys.screenName.tr
                          : AppUser.inst.nickname.value)
                      .tv(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipCard() {
    return Obx(() {
      final isVip = AppUser.inst.isVip.value;
      return TapBox(
        onTap: () {
          Get.toNamed(Routes.VIP, arguments: VipFrom.mevip);
        },
        child: SizedBox(
          width: 343.w,
          height: 206.h,
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  Assets.imagesBgMeVipCard,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: -61.h,
                right: -37.w,
                child: Opacity(
                  opacity: 0.20,
                  child: Image.asset(
                    Assets.imagesBgMeVipDiamond,
                    width: 209.w,
                    height: 209.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Assets.imagesIcVip.iv(width: 24.w, height: 24.w),
                        8.horizontalSpace,
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_accentLight, _accent],
                              stops: [0.29, 0.79],
                            ).createShader(bounds);
                          },
                          child:
                              (isVip
                                      ? LocaleKeys.vipSubscriber.tr
                                      : LocaleKeys.goVip.tr)
                                  .tv(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    _buildVipBenefits(),
                  ],
                ),
              ),
              Positioned(
                left: 16.w,
                bottom: 22.h,
                child: Container(
                  height: 32.h,
                  width: 250.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_accentLight, _accent],
                    ),
                  ),
                  child: (isVip ? LocaleKeys.accessVip.tr : 'Search').tv(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVipBenefits() {
    final style = TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      height: 1.65,
    );

    return Text.rich(
      TextSpan(
        children: buildTextSpans(
          origin: LocaleKeys.benefitsVip.tr,
          targets: const ['@1', '@2', '@3', '@4'],
          style: style,
          buildTargetTextSpan: (target, style, index) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Assets.imagesIcMeCheck.iv(width: 14.w, height: 14.w),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuPanel() {
    return Obx(() {
      final menuList = [
        _SettingMenuItem(
          title: "AI's language",
          subtitle: AppUser.inst.targetLanguage.value.label ?? 'English',
          onTap: () {
            Get.toNamed(Routes.CHOOSE_LANG);
          },
        ),
        _SettingMenuItem(
          title: LocaleKeys.shareFeedback.tr,
          onTap: () {
            toEmail();
          },
        ),
        _SettingMenuItem(
          title: controller.chatBgImagePath.value.isNotEmpty
              ? LocaleKeys.restore.tr
              : 'Set chat background',
          onTap: () {
            if (controller.chatBgImagePath.value.isNotEmpty) {
              controller.resetChatBackground();
            } else {
              controller.changeChatBackground();
            }
          },
        ),
        _SettingMenuItem(
          title: 'Privacy policy',
          onTap: () {
            toPrivacy();
          },
        ),
        _SettingMenuItem(
          title: 'Terms of us',
          onTap: () {
            toTerms();
          },
        ),
      ];

      return Container(
        width: 343.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: _panelColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: List.generate(menuList.length, (index) {
            return _buildMenuRow(
              menuList[index],
              bottomPadding: index == menuList.length - 1 ? 0 : 24.h,
            );
          }),
        ),
      );
    });
  }

  Widget _buildMenuRow(_SettingMenuItem item, {required double bottomPadding}) {
    return TapBox(
      onTap: item.onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: item.title.tv(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (item.subtitle != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.w),
                child: item.subtitle!.tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            8.horizontalSpace,
            Assets.imagesIcNext.iv(
              width: 16.w,
              height: 16.w,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditNicknameSheet() async {
    final nicknameController = TextEditingController();

    await Get.bottomSheet(
      buildTheme2SheetRootWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LocaleKeys.yourNickname.tv(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            16.verticalSpace,
            Container(
              height: 42.h,
              constraints: BoxConstraints(minHeight: 120.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cTheme.scrim, width: 1),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffFFFBD8), Colors.white, Colors.white],
                ),
              ),
              child: TextField(
                maxLines: 1,
                autofocus: true,
                controller: nicknameController,
                style: tTheme.bodyLarge!.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  hintText:
                      AppUser.inst.user?.nickname ?? LocaleKeys.screenName.tr,
                  hintStyle: tTheme.bodyLarge!.copyWith(
                    color: const Color(0xff1C1A1D).withValues(alpha: 0.25),
                  ),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                ),
              ),
            ),
            12.verticalSpace,
            SafeArea(
              child: Row(
                children: [
                  buildTheme3Btn(
                    title: LocaleKeys.cancel.tr,
                    onTap: () => Get.closeBottomSheet(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: const Color(0xff1C1A1D),
                        width: 1,
                      ),
                    ),
                  ),
                  11.horizontalSpace,
                  Expanded(
                    flex: 2,
                    child: buildTheme3Btn(
                      alignment: Alignment.center,
                      title: LocaleKeys.done.tr,
                      onTap: () async {
                        final newNickname = nicknameController.text.trim();
                        if (newNickname.isEmpty) {
                          SmartDialog.showToast(LocaleKeys.nameEmpty.tr);
                          return;
                        }
                        Get.closeBottomSheet();
                        controller.changeNickName(newNickname);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 12.w, vertical: 16.h),
      ),
      isScrollControlled: false,
    );
  }
}

class _SettingMenuItem {
  const _SettingMenuItem({
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}
