import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_config.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/sku.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/pages/vip/vip_timer.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../generated/assets.dart';
import '../../configs/constans.dart';
import '../../routes/app_pages.dart';
import '../../utils/common_utils.dart';
import '../../utils/log/log_event.dart';
import '../../utils/purchase_helper.dart';
import '../../widgets/countdown.dart';
import '../../widgets/overall_build_widget.dart';
import 'vip_controller.dart';

class VipView extends GetBuildView<VipController> {
  const VipView({super.key});

  bool get cloB => CloUtil.isCloB;
  // bool get cloB => false;

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          (cloB ? Assets.imagesBgkVip2 : Assets.imagesBgkVip).iv(
            fit: BoxFit.cover,
            width: Get.width,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.45],
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kTextTabBarHeight.verticalSpace,
                  Row(
                    children: [
                      Countdown(
                        duration: 2500.milliseconds,
                        builder: (BuildContext context, Duration remaining) {
                          if (remaining.inMilliseconds <= 0) {
                            return TapBox(
                              onTap: () => Get.back(),
                              child: buildBackIcon().marginOnly(left: 16.w),
                            );
                          }
                          return 24.verticalSpace;
                        },
                      ),
                      ex,
                      TapBox(
                        onTap: () => PurchaseHelper.inst.restore(),
                        child: Container(
                          margin: EdgeInsets.only(right: 16.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.w,
                            ),
                          ),
                          child: LocaleKeys.restorePurchase.tv(
                            style: tTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  cloB ? buildCloB() : buildCloA(),
                ],
              ),
              12.verticalSpace,
              LocaleKeys.plans
                  .tv(
                style: tTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              )
                  .marginOnly(left: 16.w,bottom: 8.h),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 250.h,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return buildProductItem(
                      sku: PurchaseHelper.inst.vipSkus[index],
                    );
                  },
                  separatorBuilder: (_, __) => 15.verticalSpace,
                  itemCount: PurchaseHelper.inst.vipSkus.length,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: buildBottomBtn(),
          ),
        ),
      ),
    );
  }

  Widget buildCloB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (Get.height / 10).verticalSpace,
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.baseline,
        //   textBaseline: TextBaseline.alphabetic,
        //   children: [
        //     ShaderMask(
        //       shaderCallback: (Rect bounds) {
        //         return LinearGradient(
        //           colors: [Color(0xffFD6A4A), cTheme.primary],
        //           begin: Alignment.centerLeft,
        //           end: Alignment.centerRight,
        //         ).createShader(bounds);
        //       },
        //       child: "50%".tv(
        //         style: tTheme.displayLarge!.copyWith(
        //           fontSize: 80.sp,
        //           fontWeight: FontWeight.w800,
        //           fontStyle: FontStyle.italic,
        //         ),
        //       ),
        //     ),
        //     12.horizontalSpace,
        //     ShaderMask(
        //       shaderCallback: (Rect bounds) {
        //         return LinearGradient(
        //           colors: [Color(0xffFD6A4A), cTheme.primary],
        //           begin: Alignment.centerLeft,
        //           end: Alignment.centerRight,
        //         ).createShader(bounds);
        //       },
        //       child: "OFF".tv(
        //         style: tTheme.displayLarge!.copyWith(
        //           fontSize: 42.sp,
        //           fontWeight: FontWeight.w800,
        //           fontStyle: FontStyle.italic,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        7.verticalSpace,
        Assets.imagesPhDiscount.iv(width: 210.w),
        6.verticalSpace,
        LocaleKeys.vipDescription.tv(
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500,color: Colors.white),
        ),
        20.verticalSpace,
        SizedBox(
          height: 132.h,
          width: Get.width,
          child: MasonryGridView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
             gridDelegate:  SliverSimpleGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 3,
             ),
            mainAxisSpacing:  6.w,
            crossAxisSpacing:  8.h,
            children: [
              ...[
                ( Assets.imagesPhVipClo1 ,LocaleKeys.vipDes2.tr),
                ( Assets.imagesPhVipBe1 , LocaleKeys.vipDes3.tr),
                ( Assets.imagesPhVipClo3 , LocaleKeys.vipDes4.trParams({"n": controller.selectedSku.number.val})),
                ( Assets.imagesPhVipClo4 , LocaleKeys.vipDes5.tr),
                ( Assets.imagesPhVipBe2 , LocaleKeys.vipDes6.tr),
                ( Assets.imagesPhVipBe4 , LocaleKeys.vipDes7.tr),
              ].map(
                (v) =>
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.black.withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child:     Row(
                            children: [
                              v.$1.iv(
                                width: 24.w,
                              ),
                              5.horizontalSpace,
                              v.$2.tv(
                                style: tTheme.bodySmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCloA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        52.verticalSpace,
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Color(0xffFBF05D), Color(0xffFDF996)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: (LocaleKeys.upgradeToVip.tr).toUpperCase().tv(
            style: tTheme.displayLarge!.copyWith(
              fontSize: 39.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        10.verticalSpace,
        LocaleKeys.enjoyBenefits.tv(
          style: tTheme.bodySmall!.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
        8.verticalSpace,
        Wrap(
          spacing: 6.w,
          runSpacing: 8.h,
          direction: Axis.horizontal,
          children:
              [
                    (Assets.imagesPhVipBe1, LocaleKeys.vipHi2.tr),
                    (Assets.imagesPhVipBe2, LocaleKeys.vipHi3.tr),
                    (Assets.imagesPhVipBe3, LocaleKeys.vipHi4.tr),
                    (Assets.imagesPhVipBe4, LocaleKeys.vipHi5.tr),
                  ]
                  .map(
                    (v) => ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.black.withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              v.$1.iv(width: 24.w),
                              5.horizontalSpace,
                              v.$2.tv(
                                style: tTheme.bodyLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ).marginSymmetric(vertical: 5.h),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    ).paddingOnly(left: 16.w);
  }

  Widget buildProductItem({required Sku sku}) {
    bool selected = controller.selectedSku == sku;
    final skuTag = SkuTag.getSkuTagByValue(sku.tag);
    return TapBox(
      onTap: () {
        controller.selectedSku = sku;
        controller.update();

        if (cloB) {
          controller.buy(sku);
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          clipBehavior:  Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: 68.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? cTheme.scrim
                          : Colors.white.withValues(alpha: 0.25),
                      width: 2.w,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  child: cloB
                      ? buildBItem(sku)
                      : buildAItem(sku, selected: selected),
                ),
              ),
            ),
            if (skuTag != null)
              Positioned(
                right: 19.w,
                top: -10.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    gradient: LinearGradient(
                      colors: [Color(0xffB0ECFD), Color(0xff78D5FA)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: "🔥${skuTag.show.tr}"
                      .tv(
                        style: tTheme.labelMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      )
                      .marginOnly(bottom: 1.h),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildAItem(Sku sku, {bool selected = false}) {
    final symbol = sku.productDetails?.currencySymbol ?? '';
    var title = '';
    String price = sku.productDetails?.price ?? '';

    final skuType = sku.skuType;
    final rawPrice = sku.productDetails?.rawPrice ?? 0;
    if (skuType == 1) {
      // price = '$rawPrice';
      title = LocaleKeys.weekly.tr;
    } else if (skuType == 2) {
      title = LocaleKeys.monthly.tr;
      // price = numFixed(rawPrice / 4, position: 2);
    } else if (skuType == 3) {
      title = LocaleKeys.yearly.tr;
      // price = numFixed(rawPrice / 48, position: 2);
    } else if (skuType == 4) {
      title = LocaleKeys.lifeTime.tr;
      // price = '$rawPrice';
    }
    // price = '$symbol$price';
    return Row(
      children: [
        Expanded(
          child: title.tv(
            style: tTheme.titleMedium?.copyWith(
              color: selected
                  ? cTheme.scrim
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        price.val.tv(
          style: tTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected
                ? cTheme.scrim
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Builder buildBItem(Sku sku) {
    return Builder(
      builder: (context) {
        final symbol = sku.productDetails?.currencySymbol ?? '';
        var title = '';
        String price = sku.productDetails?.price ?? '';

        final skuType = sku.skuType;
        final rawPrice = sku.productDetails?.rawPrice ?? 0;
        if (skuType == 1) {
          price = '$rawPrice';
          title = LocaleKeys.weekly.tr;
        } else if (skuType == 2) {
          title = LocaleKeys.monthly.tr;
          price = numFixed(rawPrice / 4, position: 2);
        } else if (skuType == 3) {
          title = LocaleKeys.yearly.tr;
          price = numFixed(rawPrice / 48, position: 2);
        } else if (skuType == 4) {
          title = LocaleKeys.lifeTime.tr;
          price = '$rawPrice';
        }
        price = '$symbol$price';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title.tv(
                      style: tTheme.titleLarge?.copyWith(
                        color: cTheme.scrim,
                        fontSize:  16.sp,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    5.verticalSpace,
                    '$symbol$rawPrice'.tv(
                      style: tTheme.bodyMedium?.copyWith(
                        fontSize: 24.sp,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: cTheme.scrim,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  skuType == 4
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            "+${sku.number}".tv(
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: cTheme.scrim,
                              ),
                            ),
                            3.horizontalSpace,
                            Assets.imagesIcGem.iv(width: 21.w),

                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            price.tv(
                              style: tTheme.headlineMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            4.horizontalSpace,
                            "/${LocaleKeys.weekly.tr}".tv(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                  3.verticalSpace,

                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBottomBtn() {
    if (cloB) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment:  Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 191.w,
                height: 46.h,
                  padding:  EdgeInsets.only(top: 3.h),
                  alignment:  Alignment.topCenter,
                  decoration:   BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(23.r),
                  ) ,
                  child: VipTimer()),
              TapBox(
                onTap: () {
                  controller.buy(controller.selectedSku);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20.w,right:  20.w,top: 35.h),
                  child: buildTheme3Btn(
                    vertical: 7.h,
                    titleWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LocaleKeys.subscribe.tv(
                          style:  TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1
                          ),
                        ),
                        5.verticalSpace,
                        LocaleKeys.recurring.tv(
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.25),
                            height: 1
                          ),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
          8.verticalSpace,
          buildPrivacyView(
            style: tTheme.labelSmall!.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              decoration: TextDecoration.underline,
            ),
          ),
          10.verticalSpace,
        ],
      );
    }
    var sku = controller.selectedSku;
    final price = sku.productDetails?.price ?? '0.0';
    var skuType = sku.skuType;

    String unit = '';
    if (skuType == 2) {
      unit = 'month';
    } else if (skuType == 3) {
      unit = 'year';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        15.verticalSpace,
        LocaleKeys.subTips
            .trParams({"price": price, "unit": unit})
            .tv(
              textAlign: TextAlign.center,
              style: tTheme.labelMedium!.copyWith(color: cTheme.onSurface),
            ),
        12.verticalSpace,
        SizedBox(
          width: Get.width,
          height: 45.h,
          child: buildTheme3Btn(
            bold: true,
            title: LocaleKeys.subscribe,
            alignment: Alignment.center,
            onTap: () {
              controller.buy(controller.selectedSku);
            },
          ),
        ),
        buildPrivacyView(
          style: tTheme.labelSmall!.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            decoration: TextDecoration.underline,
          ),
        ).marginSymmetric(vertical: 12.h),
        LocaleKeys.subTips2.tv(
          textAlign: TextAlign.center,
          style: tTheme.labelMedium!.copyWith(color: cTheme.onSurface),
        ),
      ],
    ).marginSymmetric(horizontal: 35.w);
  }
}

Widget buildPrivacyView({TextStyle? style}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      TapBox(
        onTap: () {
          toPrivacy();
        },
        padding: EdgeInsetsGeometry.all(3.r),
        child: LocaleKeys.privacy.tv(
          style:
              style ??
              tTheme.labelSmall!.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
                decoration: TextDecoration.underline,
              ),
        ),
      ),
      Container(
        height: 10.h,
        width: 1.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        color: Colors.black.withValues(alpha: 0.7),
      ),
      TapBox(
        onTap: () {
          toTerms();
        },
        padding: EdgeInsetsGeometry.all(3.r),
        child: LocaleKeys.terms.tv(
          style:
              style ??
              tTheme.labelSmall!.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
                decoration: TextDecoration.underline,
              ),
        ),
      ),
    ],
  );
}

Widget buildThemeBtn({required Widget child, onTap}) {
  return TapBox(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 7.h),
      width: Get.width / 1.4,
      decoration: BoxDecoration(
        color: cTheme.primary,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: child,
    ),
  );
}
