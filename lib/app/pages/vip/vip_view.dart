import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/sku.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../generated/assets.dart';
import '../../configs/constans.dart';
import '../../utils/common_utils.dart';
import '../../utils/purchase_helper.dart';
import '../../widgets/countdown.dart';
import '../../widgets/overall_build_widget.dart';
import 'vip_controller.dart';

class VipView extends GetBuildView<VipController> {
  const VipView({super.key});

  // bool get cloB => CloUtil.isCloB;
  bool get cloB => false;

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff111111),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  left: 16.w,
                  top: 9.h,
                  child: Countdown(
                    duration: 2500.milliseconds,
                    builder: (BuildContext context, Duration remaining) {
                      if (remaining.inMilliseconds <= 0) {
                        return TapBox(
                          onTap: () => Get.back(),
                          child: buildCloseIcon(color: Colors.white),
                        );
                      }
                      return SizedBox(width: 24.w, height: 24.w);
                    },
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 9.h,
                  child: _RestoreButton(
                    onTap: () => PurchaseHelper.inst.restore(),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  top: cloB ? 82.h : 167.h,
                  child: cloB ? _buildCloBHero() : _buildCloAHero(),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  top: cloB ? 361.h : 334.h,
                  bottom: cloB ? 150.h : 166.h,
                  child: _buildPlans(),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 24.h,
                  child: buildBottomBtn(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      cloB ? Assets.imagesBgVipDesign2 : Assets.imagesBgVipDesign1,
      fit: BoxFit.cover,
      alignment: cloB ? const Alignment(0.04, -0.16) : const Alignment(0, 0),
    );
  }

  Widget _buildCloAHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          LocaleKeys.upgradeToVip.tr.replaceAll('\n', ' '),
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
        16.verticalSpace,
        _buildBenefitList(_aBenefits),
      ],
    );
  }

  Widget _buildCloBHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _GradientText(
              '50%',
              style: TextStyle(
                fontSize: 72.sp,
                fontWeight: FontWeight.w800,
                height: 0.95,
              ),
            ),
            11.horizontalSpace,
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _GradientText(
                'OFF',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        10.verticalSpace,
        LocaleKeys.vipDescription.tv(
          style: TextStyle(
            color: cTheme.primary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        12.verticalSpace,
        _buildBenefitList(_bBenefits),
      ],
    );
  }

  List<String> get _aBenefits => [
    LocaleKeys.vipHi2.tr,
    LocaleKeys.vipHi3.tr,
    LocaleKeys.vipHi4.tr,
    LocaleKeys.vipHi5.tr,
  ];

  List<String> get _bBenefits => [
    LocaleKeys.vipDes2.tr,
    LocaleKeys.vipDes3.tr,
    LocaleKeys.vipDes4.trParams({"n": controller.selectedSku.number.val}),
    LocaleKeys.vipDes5.tr,
    LocaleKeys.vipDes6.tr,
    LocaleKeys.vipDes7.tr,
  ];

  Widget _buildBenefitList(List<String> benefits) {
    final emojis = cloB
        ? ['😃', '🥳', '💎', '👏', '🔥', '❤️']
        : ['😃', '🥳', '💎', '👏'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(benefits.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.imagesIcMeCheck.iv(
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
              4.horizontalSpace,
              Flexible(
                child: '${emojis[index]} ${benefits[index]}'.tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPlans() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return buildProductItem(sku: PurchaseHelper.inst.vipSkus[index]);
      },
      separatorBuilder: (_, _) => 8.verticalSpace,
      itemCount: PurchaseHelper.inst.vipSkus.length,
    );
  }

  Widget buildProductItem({required Sku sku}) {
    final selected = controller.selectedSku == sku;
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
        height: skuTag != null ? 82.h : 72.h,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: skuTag != null ? 10.h : 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: selected ? cTheme.primary : Colors.transparent,
                    width: 2.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: cloB
                    ? buildBItem(sku)
                    : buildAItem(sku, selected: selected),
              ),
            ),
            if (skuTag != null)
              Positioned(
                left: 0,
                top: 0,
                child: _VipRibbon(title: '🔥 ${skuTag.show.tr}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildAItem(Sku sku, {bool selected = false}) {
    return Row(
      children: [
        Expanded(
          child: _skuTitle(sku).tv(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        _skuPrice(sku).tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget buildBItem(Sku sku) {
    final rawPrice = sku.productDetails?.rawPrice ?? 0;
    final symbol = sku.productDetails?.currencySymbol ?? '';
    final weeklyPrice = _weeklyPrice(sku);
    final isLifetime = sku.skuType == 4;
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skuTitle(sku).tv(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              if (isLifetime) ...[
                2.verticalSpace,
                '$symbol${numFixed(rawPrice * 5, position: 2)}'.tv(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white.withValues(alpha: 0.7),
                    height: 1.15,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isLifetime)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.imagesIcVipDesignGem.iv(
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.contain,
                  ),
                  4.horizontalSpace,
                  '+${sku.number.val}'.tv(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              2.verticalSpace,
              _skuPrice(sku).tv(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
              ),
            ],
          )
        else
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  weeklyPrice.tv(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  4.horizontalSpace,
                  '/${LocaleKeys.weekly.tr}'.tv(
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              3.verticalSpace,
              _skuPrice(sku).tv(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildBottomBtn() {
    final sku = controller.selectedSku;
    final price = sku.productDetails?.price ?? '0.0';
    var skuType = sku.skuType;
    var unit = '';
    if (skuType == 2) {
      unit = 'month';
    } else if (skuType == 3) {
      unit = 'year';
    } else if (skuType == 4) {
      unit = LocaleKeys.lifeTime.tr;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cloB) ...[
          const _VipDesignTimer(),
          8.verticalSpace,
        ] else ...[
          LocaleKeys.subTips
              .trParams({"price": price, "unit": unit})
              .tv(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
              )
              .marginSymmetric(horizontal: 24.w),
          8.verticalSpace,
        ],
        _SubscribeButton(
          onTap: () {
            controller.buy(controller.selectedSku);
          },
        ),
        4.verticalSpace,
        _buildPrivacyLinks(
          color: cloB
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.9),
        ),
        8.verticalSpace,
        (cloB ? LocaleKeys.recurring.tr : LocaleKeys.subTips2.tr).tv(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cloB
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.82),
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            height: 1.15,
            shadows: cloB
                ? null
                : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 4.r,
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyLinks({required Color color}) {
    final linkStyle = TextStyle(
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color,
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
          color: color,
        ),
        TapBox(
          onTap: toTerms,
          padding: EdgeInsetsGeometry.all(3.r),
          child: LocaleKeys.terms.tv(style: linkStyle),
        ),
      ],
    );
  }

  String _skuTitle(Sku sku) {
    switch (sku.skuType) {
      case 1:
        return LocaleKeys.weekly.tr;
      case 2:
        return LocaleKeys.monthly.tr;
      case 3:
        return LocaleKeys.yearly.tr;
      case 4:
        return LocaleKeys.lifeTime.tr;
      default:
        return sku.name ?? '';
    }
  }

  String _skuPrice(Sku sku) {
    return sku.productDetails?.price ?? '';
  }

  String _weeklyPrice(Sku sku) {
    final symbol = sku.productDetails?.currencySymbol ?? '';
    final rawPrice = sku.productDetails?.rawPrice ?? 0;
    if (sku.skuType == 2) {
      return '$symbol${numFixed(rawPrice / 4, position: 2)}';
    }
    if (sku.skuType == 3) {
      return '$symbol${numFixed(rawPrice / 48, position: 2)}';
    }
    return _skuPrice(sku);
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: LocaleKeys.restorePurchase.tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffffdffd), Color(0xffff96f7)],
          stops: [0.058, 0.922],
        ).createShader(bounds);
      },
      child: text.tv(style: style.copyWith(color: Colors.white)),
    );
  }
}

class _VipRibbon extends StatelessWidget {
  const _VipRibbon({required this.title});

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

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({required this.onTap});

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
        child: LocaleKeys.subscribe.tv(
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

class _VipDesignTimer extends StatefulWidget {
  const _VipDesignTimer();

  @override
  State<_VipDesignTimer> createState() => _VipDesignTimerState();
}

class _VipDesignTimerState extends State<_VipDesignTimer> {
  int minutes = 30;
  int seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (seconds == 0) {
          if (minutes == 0) {
            timer.cancel();
          } else {
            minutes--;
            seconds = 59;
          }
        } else {
          seconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        'Expiration time:'.tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        10.horizontalSpace,
        _TimerDigit(minutesStr),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: ':'.tv(
            style: TextStyle(
              color: const Color(0xff59cfff),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        _TimerDigit(secondsStr),
      ],
    );
  }
}

class _TimerDigit extends StatelessWidget {
  const _TimerDigit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xff59cfff).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: text.tv(
        style: TextStyle(
          color: const Color(0xff59cfff),
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
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
