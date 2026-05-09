import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:novatalk/app/pages/call/phone_ctr.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../generated/assets.dart';
import '../../configs/constans.dart';
import '../../entities/role_entity.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> with RouteAware {
  late final ctr = Get.find<PhoneCtr>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Positioned.fill(child: _buildBackground()),
            SafeArea(
              child: Stack(
                children: [
                  Align(alignment: Alignment.topCenter, child: _buildTimer()),
                  Positioned(
                    right: 16.w,
                    top: 11.h,
                    child: TapBox(
                      onTap: ctr.onTapHangup,
                      child: buildCloseIcon(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 108.h,
                    left: 0,
                    right: 0,
                    child: Center(child: _PhoneProfileCard(role: ctr.role)),
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 168.h,
                    child: Obx(() => _buildAnswering()),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 44.h,
                    child: Obx(() {
                      ctr.callState.value;
                      return _buildControlButtons();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        (ctr.guideVideo?.gifUrl ?? ctr.role.avatar).iv(fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Obx(() {
      final text = ctr.showFormattedDuration.value
          ? ctr.formattedDuration(ctr.callDuration.value)
          : '00:00';
      return Container(
        height: 32.h,
        margin: EdgeInsets.only(top: 7.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4747),
                shape: BoxShape.circle,
              ),
            ),
            4.horizontalSpace,
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnswering() {
    final text = ctr.callStateDescription(ctr.callState.value);
    if (text.isEmpty) {
      return sh;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF262626).withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
          child: AnimatedTextKit(
            key: ValueKey('${ctr.callState.value}-$text'),
            totalRepeatCount: 1,
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                speed: const Duration(milliseconds: 50),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CallControlButton(
          backgroundColor: hangupColor,
          icon: Assets.imagesIcCallHangup.iv(
            width: 32.w,
            height: 32.w,
            fit: BoxFit.contain,
          ),
          onTap: ctr.onTapHangup,
        ),
        117.horizontalSpace,
        _buildPrimaryActionButton(),
      ],
    );
  }

  Widget _buildPrimaryActionButton() {
    final state = ctr.callState.value;
    if (state == CallState.incoming) {
      return _CallControlButton(
        backgroundColor: answerColor,
        icon: Assets.imagesIcCallAnswer.iv(
          width: 32.w,
          height: 32.w,
          fit: BoxFit.contain,
        ),
        onTap: ctr.onTapAccept,
      );
    }
    if (state == CallState.listening) {
      return _CallControlButton(
        backgroundColor: const Color(0xFF4CDA64),
        outerColor: const Color(0xFF4CDA64).withValues(alpha: 0.30),
        innerSize: 52.w,
        innerRadius: 12.r,
        icon: Assets.imagesIcCallMic.iv(
          width: 32.w,
          height: 32.w,
          color: Colors.white,
          fit: BoxFit.contain,
        ),
        onTap: () => ctr.onTapMic(false),
      );
    }
    return _CallControlButton(
      backgroundColor: const Color(0xFFE6E6E6),
      icon: Icon(Icons.mic_off_outlined, color: Colors.black, size: 32.w),
      onTap: () => ctr.onTapMic(true),
    );
  }
}

class _PhoneProfileCard extends StatelessWidget {
  const _PhoneProfileCard({required this.role});

  final RoleRecords role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: Stack(
              children: [
                Positioned(
                  left: 4.w,
                  top: 4.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: role.avatar.iv(
                      width: 72.w,
                      height: 72.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFFF96F7)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 108.w),
                child: Text(
                  role.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (role.age != null) ...[
                4.horizontalSpace,
                _CallAgeBadge(age: role.age!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CallAgeBadge extends StatelessWidget {
  const _CallAgeBadge({required this.age});

  final int age;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
        ),
      ),
      child: '$age'.tv(
        style: TextStyle(
          color: Colors.black,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
    this.outerColor,
    this.innerSize,
    this.innerRadius,
  });

  final Color backgroundColor;
  final Color? outerColor;
  final Widget icon;
  final VoidCallback onTap;
  final double? innerSize;
  final double? innerRadius;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: SizedBox(
        width: 64.w,
        height: 64.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: outerColor ?? backgroundColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Container(
              width: innerSize ?? 64.w,
              height: innerSize ?? 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(innerRadius ?? 16.r),
              ),
              child: icon,
            ),
          ],
        ),
      ),
    );
  }
}

Widget topRoleInfoView(RoleRecords role) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () => Get.back(),
        child: buildBackIcon(),
      ).marginOnly(left: 16.w),
      8.horizontalSpace,
      ClipOval(
        child: role.avatar.iv(width: 36.w, height: 36.w),
      ),
      8.horizontalSpace,
      role.name.tv(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      6.horizontalSpace,
      if (role.age != null) _CallAgeBadge(age: role.age!),
      // PhoneTitle(role: role)
    ],
  ).paddingOnly(bottom: 4.h);
}

const hangupColor = Color(0xffE2266C);
const answerColor = Color(0xff4CDA64);
