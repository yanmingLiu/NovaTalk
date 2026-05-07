import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/pages/undr/undr_page.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';
import 'ctls/purchase_controller.dart';

class PurchasePage extends GetView<PurchaseController> {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: buildDefaultBg(
        child: SafeArea(
          child: Stack(
            children: [
              // Container(
              // height: 120.h,
              // decoration: const BoxDecoration(),
              // child: Center(
              //   child: Image.asset(
              //     controller.args.isPayPhotoNum == true
              //         ? Assets.assetsImagesIcPurchaseP
              //         : Assets.assetsImagesIcPurchaseV,
              //     width: 120.w,
              //   ).marginOnly(top: 70.h),
              // ),
              // ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  LocaleKeys.purBalance.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Color(0xff1C1A1D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 12.w,
                child: TapBox(
                  onTap: () {
                    Get.back();
                  },
                  child: buildBackIcon(color:  Colors.black),
                ),
              ),
              Column(
                children: [
                  40.verticalSpace,
                  Expanded(
                    child: Obx(
                      () => ListView.separated(
                        shrinkWrap:    true ,
                        itemCount: controller.purchases.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemBuilder: (BuildContext context, int index) {
                          return buildItem(index);
                        }, separatorBuilder: (BuildContext context, int index) {
                          return 8.verticalSpace;
                      },
                      ),
                    ),
                  ),
                  SafeArea(
                    child: TapBox(
                      onTap: () {
                        controller.buy(controller.selectedPurchase.value);
                      },
                      child: buildUndrBtn(
                        bold: true,
                        title: LocaleKeys.pressConti.tr,
                      ),
                    ).marginSymmetric(horizontal: 12.w),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    var sku = controller.purchases[index];
    return Obx(() {
      bool isSelected = controller.selectedPurchase.value == sku;
      return TapBox(
        onTap: () {
          controller.selectedPurchase.value = sku;
          controller.selectedPurchase.refresh();
          controller.buy(controller.selectedPurchase.value);
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: double.infinity,
              height: 97. h,
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Color(0x1AFFFFFF),
                border: isSelected
                    ? Border.all(color: cTheme.primary, width: 1.w)
                    : Border.all(color: Color(0xffEAEAEA), width: 1.w),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment:  CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(controller.getPower(sku),style:  TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff1C1A1D)
                        )),
                        4.horizontalSpace,
                        Text(controller.getPayType,style:  TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xff1C1A1D),
                            fontWeight: FontWeight.w500
                        ),),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize:  MainAxisSize.min,
                    children: [
                      Text(
                        (sku.productDetails?.price).val,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.imagesIcGem.iv(width: 16.w),
                          5.horizontalSpace,
                          Text(
                            "+${sku.number}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ).marginSymmetric(vertical: 3.h),
                      Text(
                        controller.getUnitPrice(sku),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if(isSelected)
            Positioned(
                right: 0,
                bottom: 0,
                child: Assets.imagesPhCheck2.iv(width: 16.w)),
            if (sku.tag == SkuTag.topPopular.value ||
                sku.tag == SkuTag.greatest.value)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.h,vertical: 3.h ),
                margin: EdgeInsets.only(left: 20.w),
                decoration: BoxDecoration(
                  borderRadius:  BorderRadius.all(Radius.circular( 12.r)),
                  gradient:  LinearGradient(
                    colors: [
                     Color(0xff78D5FA),
                     Color(0xffB0ECFD),
                    ],
                  ),
                ),
                child: Text(
                  sku.tag == SkuTag.topPopular.value
                      ? LocaleKeys.mostRated.tr
                      : LocaleKeys.bestDeal.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
