import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/constans.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/assets.dart';

const homeTopEntryPurple = Color(0xFFC7ABFF);

class HomeGemPill extends StatelessWidget {
  const HomeGemPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TapBox(
        onTap: () {
          pushGem(ConsumeFrom.home);
        },
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.imagesIcGem.iv(width: 20.w, height: 20.w),
              4.horizontalSpace,
              AppUser.inst.balance.value.tv(
                style: TextStyle(
                  color: homeTopEntryPurple,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeVipEntry extends StatelessWidget {
  const HomeVipEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      child: Assets.imagesIcVip.iv(width: 24.w),
    );
  }
}
