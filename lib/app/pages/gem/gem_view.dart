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
import '../../utils/common_utils.dart';
import '../../utils/log/log_event.dart';
import '../../widgets/common_widget.dart';
import 'gem_controller.dart';

class GemView extends GetBuildView<GemController> {
  const GemView({super.key});

  // bool get isCloB => CloUtil.isCloB;
  bool get isCloB => false;

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              right: 16.w,
              top: 11.h,
              child: _buildTopBar(),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              top: 55.h,
              child: _buildHeaderTip(),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              top: isCloB ? 155.h : 115.h,
              bottom: 128.h,
              child: _buildSkuGrid(),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 26.h,
              child: bottomMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        TapBox(
          onTap: () => Get.back(),
          child: buildBackIcon(color: Colors.white),
        ),
        ex,
        _GlassCircleButton(
          onTap: showQA,
          child: "?".tv(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTip() {
    return Center(
      child: Container(
        width: isCloB ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xff390034), Colors.black],
            stops: [0.048, 1],
          ),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: (isCloB ? LocaleKeys.gemTips : LocaleKeys.gemTips3).tv(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSkuGrid() {
    return GridView.builder(
      itemCount: PurchaseHelper.inst.coinsSkus.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return buildItem(index);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 8.h,
      ),
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
                () => AppUser.inst.balance.value.tv(
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
              style: TextStyle(
                color: const Color(0xff808080).withValues(alpha: 0.85),
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
            )
            .marginSymmetric(horizontal: 2.w),
        6.verticalSpace,
        _GradientBuyButton(
          onTap: () {
            logEvent('c_paygems');
            buy();
          },
        ),
        4.verticalSpace,
        _buildPrivacyLinks(),
      ],
    );
  }

  Widget _buildPrivacyLinks() {
    final linkStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      decoration: TextDecoration.underline,
      decorationColor: Colors.white.withValues(alpha: 0.7),
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapBox(
          onTap: toPrivacy,
          padding: EdgeInsetsGeometry.all(3.r),
          child: LocaleKeys.privacy.tv(style: linkStyle),
        ),
        Container(
          height: 10.h,
          width: 1.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          color: Colors.white.withValues(alpha: 0.7),
        ),
        TapBox(
          onTap: toTerms,
          padding: EdgeInsetsGeometry.all(3.r),
          child: LocaleKeys.terms.tv(style: linkStyle),
        ),
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
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: skuTag != null ? 8.h : 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: isSelected ? cTheme.primary : Colors.transparent,
                  width: 2.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCloB)
                    controller.discount[discountIndex].tv(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  price.tv(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  16.verticalSpace,
                  Assets.imagesIcGemDesign.iv(
                    width: isCloB ? 48.w : 52.w,
                    height: isCloB ? 48.w : 52.w,
                    fit: BoxFit.contain,
                  ),
                  4.verticalSpace,
                  "+${sku.number}".tv(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (skuTag != null)
            Positioned(
              left: 0,
              top: 0,
              child: _SkuRibbon(title: "🔥 ${skuTag.show.tr}"),
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
      if (isCloB)
        (
          Assets.imagesPhGem3,
          'Generate image: @n Gems/ image',
          '${ConsumeFrom.creaimg.gems}',
        ),
      if (isCloB)
        (
          Assets.imagesPhVideoPlay,
          'Generate video: @n Gems/ video',
          '${ConsumeFrom.creavideo.gems}',
        ),
    ];
    Get.dialog(
      _RechargeRulesDialog(tips: tips, isCloB: isCloB),
      barrierColor: Colors.black.withValues(alpha: 0.72),
      useSafeArea: false,
    );
  }
}

class _RechargeRulesDialog extends StatelessWidget {
  const _RechargeRulesDialog({required this.tips, required this.isCloB});

  final List<(String, String, String)> tips;
  final bool isCloB;

  @override
  Widget build(BuildContext context) {
    final backgroundHeight = isCloB ? 506.h : 338.h;
    final height = backgroundHeight + 48.h;
    final top = isCloB ? 108.h : 178.h;
    final titleTop = 159.h;
    final contentTop = 203.h;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: top,
            child: SizedBox(
              width: 343.w,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child:
                        (isCloB
                                ? Assets.imagesBgShowQa2
                                : Assets.imagesBgShowQa1)
                            .iv(
                              width: 343.w,
                              height: backgroundHeight,
                              fit: BoxFit.fill,
                            ),
                  ),
                  Positioned(
                    left: 14.w,
                    right: 14.w,
                    top: titleTop,
                    child: LocaleKeys.vipDes1.tv(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    top: contentTop,
                    child: Column(
                      children: [
                        for (var i = 0; i < tips.length; i++)
                          _buildRuleItem(
                            tips[i],
                            hasBottomGap: i < tips.length - 1,
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: TapBox(
                      onTap: Get.closeDialog,
                      child: buildCloseIcon(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(
    (String, String, String) item, {
    required bool hasBottomGap,
  }) {
    final (_, title, price) = item;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: hasBottomGap ? 8.h : 0),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Assets.imagesIcGemDesign.iv(
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
          12.horizontalSpace,
          Expanded(
            child: title
                .trParams({'n': price})
                .tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: Container(
        width: 24.w,
        height: 24.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff131711).withValues(alpha: 0.18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 0.6.w,
          ),
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.25),
              blurRadius: 4.r,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _GradientBuyButton extends StatelessWidget {
  const _GradientBuyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: Container(
        width: 250.w,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffffdffd), Color(0xffff96f7)],
            stops: [0.058, 0.922],
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: LocaleKeys.buy.tv(
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _SkuRibbon extends StatelessWidget {
  const _SkuRibbon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffffdffd), Color(0xffff96f7)],
          stops: [0.058, 0.922],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: title.tv(
        style: TextStyle(
          color: const Color(0xff222222),
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

Future showGetGemSuccess({String num = "888"}) {
  return Get.dialog(_GetGemSuccessDialog(num: num));
}

class _GetGemSuccessDialog extends StatelessWidget {
  const _GetGemSuccessDialog({required this.num});

  final String num;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, -34.h),
          child: SizedBox(
            width: 250.w,
            height: 250.h,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  left: 8.w,
                  top: 0,
                  child: TapBox(
                    onTap: Get.closeDialog,
                    child: buildCloseIcon(color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 54.h,
                  child: LocaleKeys.gems.tv(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  top: 112.h,
                  child: Assets.imagesIcGemDesign.iv(
                    width: 145.w,
                    height: 145.w,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 112.h,
                  right: 10.w,
                  child: _GemSuccessBadge(num: num),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GemSuccessBadge extends StatelessWidget {
  const _GemSuccessBadge({required this.num});

  final String num;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      constraints: BoxConstraints(minWidth: 92.w),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffffdffd), Color(0xffff96f7)],
          stops: [0.058, 0.922],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
          bottomRight: Radius.circular(15.r),
          bottomLeft: Radius.circular(1.r),
        ),
      ),
      child: "+$num".tv(
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
