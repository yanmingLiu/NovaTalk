import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/utils/purchase_helper.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';
import '../../utils/app_user.dart';
import '../../utils/clo_util.dart';
import '../../utils/log/log_event.dart';
import '../../widgets/common_widget.dart';
import '../vip/vip_view.dart';
import 'gem_controller.dart';

class GemView extends GetBuildView<GemController> {
  const GemView({super.key});

  bool get isCloB => CloUtil.isCloB;

  // bool get isCloB => false;

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      body: buildDefaultBg(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    TapBox(
                      onTap: () => Get.back(),
                      child: buildBackIcon(color: Colors.black),
                    ),
                    ex,
                    TapBox(
                      onTap: () {
                        showQA();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffC3B600).withValues(alpha: 0.25),
                          ),
                          color: cTheme.scrim.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: LocaleKeys.rules.tv(
                          style: tTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                20.verticalSpace,
                buildGemBalance(),
                28.verticalSpace,
                (isCloB ? LocaleKeys.gemTips : LocaleKeys.gemTips3)
                    .tv(
                      style: tTheme.bodyLarge?.copyWith(
                        color: Color(0xff8C8C8C),
                      ),
                      textAlign: TextAlign.center,
                    )
                    .marginSymmetric(horizontal: 45.w),

                20.verticalSpace,
                GridView.builder(
                  itemCount: PurchaseHelper.inst.coinsSkus.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return buildItem(index);
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 7.w,
                    mainAxisSpacing: 12.w,
                  ),
                ),
                70.verticalSpace,
              ],
            ).marginSymmetric(horizontal: 16.w),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(child: bottomMenu()),
    );
  }

  Widget buildGemBalance() {
    return Container(
      height: 104.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        image: DecorationImage(
          image: AssetImage(Assets.imagesBgkSetVip),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.imagesIcGem.iv(width: 25.w),
              10.horizontalSpace,
              Obx(
                ()=> AppUser.inst.balance.value.tv(
                  style: tTheme.bodyLarge?.copyWith(
                    color: cTheme.scrim,
                    fontWeight: FontWeight.w700,
                    fontSize: 36.sp,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          3.verticalSpace,
          LocaleKeys.remaining.tv(style: tTheme.bodySmall),
        ],
      ),
    );
  }

  Widget bottomMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LocaleKeys.gemTips2
            .trParams({
              "price": (controller.selectedSku?.productDetails?.price).val,
            })
            .tv(
              style: tTheme.labelMedium!.copyWith(
                color: Color(0xff1C1A1D).withValues(alpha: 0.5)
              ),
              textAlign: TextAlign.center,
            )
            .marginSymmetric(horizontal: 45.w),

        buildTheme3Btn(
          vertical: 11.h,
          alignment: Alignment.center,
          titleWidget: LocaleKeys.buy.tv(style: tTheme.titleLarge!.copyWith(color: Colors.black)),
          onTap: () {
            logEvent('c_paygems');
            buy();
          },
        ).marginSymmetric(vertical: 8.h, horizontal: 12.w),
        buildPrivacyView(),
        20.horizontalSpace,
      ],
    );
  }

  Widget buildItem(int index) {
    var sku = PurchaseHelper.inst.coinsSkus[index];
    var price = sku.productDetails?.price ?? '';
    bool isSelected = controller.selectedSku == sku;
    int discountIndex = index;
    if (index >= controller.discount.length) {
      discountIndex = controller.discount.length - 1;
    }
    final skuTag = SkuTag.getSkuTagByValue(sku.tag);
    return TapBox(
      onTap: () {
        controller.selectedSku = sku;
        controller.update();
        if (isCloB) {
          buy();
        }
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            width: double.infinity,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 10.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? cTheme.scrim : Color(0xffEAEAEA),
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: "${sku.number}".tv(
                    style: tTheme.headlineLarge?.copyWith(
                      color: Colors.black,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                price.tv(
                  style: tTheme.bodyLarge?.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              top: 10.h,
              child: Assets.imagesPhCheck.iv(width: 16.w),
            ),
          if (isCloB)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xffF2913C), Color(0xffFF7F29)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: controller.discount[discountIndex].tv(
                  style: tTheme.bodySmall,
                ),
              ),
            ),
          if (skuTag != null)
            Container(
              margin: EdgeInsets.only(left: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
                gradient: LinearGradient(
                  colors: [Color(0xffB0ECFD), Color(0xff78D5FA)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              child: "🔥 ${skuTag.show.tr}".tv(
                style: tTheme.bodySmall?.copyWith(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  void buy() {
    controller.buy(
      onCompletePurchase: () {
        showGetGemSuccess(num: (controller.selectedSku?.number).val);
      },
    );
  }

  void showQA() {
    final tips = [
      (
        Assets.imagesPhGemText,
        LocaleKeys.sendMsg.tr,
        AppUser.inst.sendMsgPrice,
      ),
      (
        Assets.imagesPhGemAudio,
        LocaleKeys.sendAudio.tr,
        AppUser.inst.sendAudioMsgPrice,
      ),
      if (isCloB)
        (
          Assets.imagesPhGemCall,
          LocaleKeys.callRole.tr,
          AppUser.inst.callPrice,
        ),
    ];
    Widget buildItem(tips) {
      final (String icon, String title, String price) = tips;
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffEAEAEA)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon.iv(width: 28.w),
            5.verticalSpace,
            title.trParams({'n' : price}).tv(style: tTheme.bodyLarge?.copyWith(color: Colors.black)),
            5.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.imagesIcGem.iv(width: 24.w),
                5.horizontalSpace,
                price.tv(
                  style: tTheme.bodyLarge?.copyWith(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      );
    }

    showTheme1Sheet(
      showCancel: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocaleKeys.vipDes1
              .tv(style: tTheme.bodyLarge?.copyWith(color: Colors.black))
              .marginSymmetric(vertical: 16.h),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.33,
              crossAxisSpacing: 7.w,
              mainAxisSpacing: 7.w,
            ),
            shrinkWrap: true,

            itemCount: tips.length,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemBuilder: (context, index) {
              return buildItem(tips[index]);
            },
          ),
        ],
      ),
    );
  }
}

Future showGetGemSuccess({String num = "888"}) {
  return Get.dialog(
    Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Assets.imagesPhGem2.iv().marginOnly(top: 40.h),
        Container(
          margin: EdgeInsets.only(top: 250.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              "+$num".tv(
                style: tTheme.displayLarge?.copyWith(fontStyle: FontStyle.italic),
              ),
              10.horizontalSpace,
              LocaleKeys.gems.tv(style: tTheme.headlineSmall),
            ],
          ),
        ),
        Positioned(
            right: 30.w,
            child: TapBox(
                onTap:  () {
                  Get.closeDialog();
                },
                child: buildCloseIcon().marginOnly(bottom: 180.h)))
      ],
    ),
  );
}
