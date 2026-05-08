import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/sku.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';
import 'ctls/purchase_controller.dart';

const _purchaseAccent = Color(0xFFFF96F7);
const _purchaseAccentLight = Color(0xFFFFDFFD);

class PurchasePage extends GetView<PurchaseController> {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                11.verticalSpace,
                Expanded(
                  child: Obx(() {
                    final isPhotoPurchase = controller.args.isPayPhotoNum;
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.purchases.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: isPhotoPurchase ? 175.h : 164.h,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 15.w,
                      ),
                      itemBuilder: (context, index) => _buildItem(index),
                    );
                  }),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 72.h,
              child: Center(
                child: _PurchaseActionButton(
                  title: LocaleKeys.pressConti.tr,
                  onTap: () {
                    controller.buy(controller.selectedPurchase.value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44.h,
      width: Get.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16.w,
            child: TapBox(
              onTap: Get.back,
              child: buildBackIcon(color: Colors.white),
            ),
          ),
          Text(
            LocaleKeys.purBalance.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final sku = controller.purchases[index];
    return Obx(() {
      final isSelected = controller.selectedPurchase.value == sku;
      final isPhotoPurchase = controller.args.isPayPhotoNum;
      final showTag = _shouldShowTag(sku);
      return TapBox(
        onTap: () {
          controller.selectedPurchase.value = sku;
          controller.selectedPurchase.refresh();
          controller.buy(controller.selectedPurchase.value);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: isPhotoPurchase ? null : (showTag ? 8.h : 0),
              bottom: isPhotoPurchase ? 0 : null,
              child: _PurchaseSkuCard(
                sku: sku,
                isSelected: isSelected,
                photoType: controller.getPayType,
                power: controller.getPower(sku),
                unitPrice: controller.getUnitPrice(sku),
                showReward: isPhotoPurchase,
              ),
            ),
            if (showTag)
              Positioned(
                left: 0,
                top: 0,
                child: _PurchaseSkuTag(title: _tagTitle(sku)),
              ),
          ],
        ),
      );
    });
  }

  bool _shouldShowTag(Sku sku) {
    if (!controller.args.isPayPhotoNum) {
      return sku.tag == SkuTag.greatest.value;
    }
    return sku.tag == SkuTag.topPopular.value ||
        sku.tag == SkuTag.greatest.value;
  }

  String _tagTitle(Sku sku) {
    if (!controller.args.isPayPhotoNum && sku.tag == SkuTag.greatest.value) {
      return '🔥 Best Value';
    }
    return sku.tag == SkuTag.topPopular.value
        ? LocaleKeys.mostRated.tr
        : LocaleKeys.bestDeal.tr;
  }
}

class _PurchaseSkuCard extends StatelessWidget {
  const _PurchaseSkuCard({
    required this.sku,
    required this.isSelected,
    required this.photoType,
    required this.power,
    required this.unitPrice,
    required this.showReward,
  });

  final Sku sku;
  final bool isSelected;
  final String photoType;
  final String power;
  final String unitPrice;
  final bool showReward;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164.w,
      height: 164.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(color: _purchaseAccent, width: 2.w)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$power $photoType',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showReward) ...[
            4.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.imagesIcGem.iv(width: 24.w, height: 24.w),
                4.horizontalSpace,
                Text(
                  '+${sku.number ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            8.verticalSpace,
          ] else
            16.verticalSpace,
          Text(
            (sku.productDetails?.price).val,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          4.verticalSpace,
          Text(
            unitPrice,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseSkuTag extends StatelessWidget {
  const _PurchaseSkuTag({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_purchaseAccentLight, _purchaseAccent],
        ),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF222222),
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PurchaseActionButton extends StatelessWidget {
  const _PurchaseActionButton({required this.title, required this.onTap});

  final String title;
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
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_purchaseAccentLight, _purchaseAccent],
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
