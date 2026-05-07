import 'package:novatalk/app/pages/undr/undr_page.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';
import 'package:novatalk/generated/assets.dart';
import 'package:novatalk/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../configs/app_theme.dart';
import '../../../entities/create_style_bean.dart';
import '../../../routes/app_pages.dart';
import 'picture_controller.dart';

class PictureView extends GetView<PictureController> {
  const PictureView({super.key});

  @override
  Widget build(BuildContext context) {
    return ReleaseTextEditFocus(
      child: Scaffold(
        body: buildDefaultBg(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAppbar(),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          buildDescription(),
                          buildTheme(),
                          buildCount(),
                          buildRatio(),
                          buildSubmit(),
                          20.verticalSpace,
                        ],
                      ),
                    ),
                    Obx(()=> controller.generating.value? buildProcessView():sh)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppbar() {
    return SafeArea(
      child: Row(
        children: [
          DefaultTabController(
            length: 1,
            child: buildHomeTitleTabBar(
              tabs: [Tab(text: LocaleKeys.appLabel.tr)],
            ),
          ),
          ex,
          TapBox(
            onTap: () {
              Get.toNamed(Routes.CREATIONS);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Color(0xFFFBF05D),
                border: Border.all(
                  color: Color(0xFFC3B600).withValues(alpha: 0.25),
                  width: 1.r,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
              child: LocaleKeys.creations.tv(
                style: tTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
            ),
          ),
          8.horizontalSpace,
          buildGemWidget(),
          12.horizontalSpace,
        ],
      ),
    );
  }

  Widget buildDescription() {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.h),
      decoration: BoxDecoration(
        border: Border.all(color: cTheme.scrim, width: 1.r),
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 12.w,
                  top: 10.h,
                  bottom: 12.h,
                  right: 12.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFEFBD6), Color(0xFFFFFBDA)],
                  ),
                ),
                child: Row(
                  children: [
                    LocaleKeys.inputDescription.tv(
                      style: tTheme.bodyMedium?.copyWith(
                        color: Color(0xff595959),
                        fontSize: 12.sp,
                        fontWeight:  FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    ex,
                    TapBox(
                      onTap: () {
                        controller.clearPrompt();
                      },
                      padding: EdgeInsets.all(2.r),
                      child: Assets.imagesPhDelete.iv(width: 14.w),
                    ),
                  ],
                ),
              ),
              Container(
                height: 123.h,
                child: RawScrollbar(
                  controller: controller.scrollController,
                  thumbVisibility: true,
                  thickness: 4.w,
                  radius: Radius.circular(2.r),
                  thumbColor: Color(0xFFEDEDED),
                  padding: EdgeInsets.only(top: 4.h),
                  child: Obx(
                    () => TextField(
                      scrollController: controller.scrollController,
                      controller: controller.promptTextController,
                      maxLines: null,
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: tTheme.bodyLarge?.copyWith(color: Colors.black),
                      maxLength: 500,
                      buildCounter:
                          (
                            BuildContext context, {
                            int? currentLength,
                            int? maxLength,
                            bool? isFocused,
                          }) {
                            return Padding(
                              padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
                              child: Text(
                                '$currentLength/$maxLength',
                                style: TextStyle(
                                  color: currentLength == maxLength
                                      ? Color(0xFFDF0B77)
                                      : Color(0xFFCDCDCD),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        border: InputBorder.none,
                        hintText: controller.initPrompt.value,
                        hintMaxLines: 4,
                        hintStyle: tTheme.bodyLarge?.copyWith(
                          color: Color(0xFFCDCDCD),
                        ),
                      ),
                    ),
                  ),
                ),
              ).marginOnly(bottom: 12.h),
            ],
          ),
          TapBox(
            onTap: () {
              controller.aiWrite();
            },
            child: Container(
              margin: EdgeInsets.only(left: 12.w, bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.5.h),
              decoration: BoxDecoration(
                color: cTheme.scrim.withValues(alpha: 0.25),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.imagesPhAiWrite.iv(width: 10.w),
                  LocaleKeys.aiWrite.tv(
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF262626),
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

  Widget buildTheme() {
    Widget buildStyleView(List<CreateStyleBean> styles) {
      return Container(
        height: 108.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          scrollDirection: Axis.horizontal,
          itemCount: styles.length,
          separatorBuilder: (context, index) {
            return 6.5.horizontalSpace;
          },
          itemBuilder: (context, index) {
            final style = styles[index];
            final isSelected = controller.selectedStyle == style;
            return TapBox(
              onTap: () {
                controller.selectStyle(style);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected?Colors.white:Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(
                    color: isSelected ? cTheme.scrim : Colors.transparent,
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      child: style.cover.iv(width: 80.w, height: 80.w),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: style.name.tv(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF434343),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }


    return Obx(() {
      final List<CreateStyleBean> styles = controller.styleList.value;
      styles.where((v) => v.styleType == 0);
      List<CreateStyleBean> real = [];
      List<CreateStyleBean> fantasy = [];
      for (var n in styles) {
        if (n.styleType == 0) {
          real.add(n);
        } else {
          fantasy.add(n);
        }
      }
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            15.verticalSpace,
            buildHomeTabBar(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
              onTap: (index) {
                controller.styleList.refresh();
              },
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.68),
              ),
              tabs: [
                Tab(text: LocaleKeys.real.tr),
                Tab(text: LocaleKeys.fantasy.tr),
              ],
            ),
            6.verticalSpace,
            Builder(
              builder: (context) {
                final index = DefaultTabController.of(context).index;
                return IndexedStack(
                  index: index,
                  children: [buildStyleView(real), buildStyleView(fantasy)],
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget buildCount() {
    return Row(
      children: [
        LocaleKeys.numImages.tv(
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        ex,
        Container(
          width: 162.w,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFFAFAFA), width: 1.w),
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
          ),
          child: Obx(
            () => Row(
              children: [
                TapBox(
                  padding: EdgeInsets.all(4.r),
                  onTap: () {
                    if (controller.count > 1) {
                      controller.count.value--;
                    }
                  },
                  child:
                      (controller.count.value > 1
                              ? Assets.imagesPhCountReduce2
                              : Assets.imagesPhCountReduce)
                          .iv(width: 20.w),
                ),
                Expanded(
                  child: Center(
                    child: controller.count.value.tv(
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                TapBox(
                  padding: EdgeInsets.all(4.r),
                  onTap: () {
                    if (controller.count.value >= 4) {
                      return;
                    }
                    controller.count.value++;
                  },
                  child:
                      (controller.count.value < 4
                              ? Assets.imagesPhCountAdd2
                              : Assets.imagesPhCountAdd)
                          .iv(width: 20.w),
                ),
              ],
            ),
          ),
        ),
      ],
    ).marginSymmetric(horizontal: 12.w, vertical: 20.h);
  }

  Widget buildRatio() {
    final ratios = [
      (value: "1:1", ui: 1.0, title: LocaleKeys.square, width: 28.0.w),
      (value: "9:16", ui: 9 / 14, title: LocaleKeys.igStore, width: 30.0.w),
      (
        value: "9:19",
        ui: 9 / 14,
        title: LocaleKeys.igFullscreen,
        width: 30.0.w,
      ),
      (value: "4:3", ui: 1.33, title: LocaleKeys.socialMedia, width: 26.0.w),
    ];
    ui:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleKeys.imageRatio
            .tv(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 1,
                color: Colors.black,
              ),
            )
            .marginOnly(left: 12.w),
        12.verticalSpace,
        SizedBox(
          height: 100.h,
          width: Get.width,
          child: Obx(() {
            controller.ratio.value;
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final ratio = ratios[index];
                final isSelected = controller.ratio.value == ratio.value;
                return TapBox(
                  onTap: () {
                    controller.ratio.value = ratio.value;
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 80.w,
                          child: Column(
                            children: [
                              Container(
                                height: 76.h,
                                padding: EdgeInsets.only(top: 15.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.r),
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? cTheme.scrim
                                        : Color(0xFFFAFAFA),
                                    width: 1.w,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: ratio.width,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: ratio.ui,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6.r),
                                            ),
                                            border: Border.all(
                                              color: Color(0xFF8C8C8C),
                                              width: 2.5.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ex,
                                    Text(
                                      "${ratio.value}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    8.verticalSpace,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ratio.title.tv(
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.black : Color(0xFF8C8C8C),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => 10.horizontalSpace,
              itemCount: ratios.length,
            );
          }),
        ),
      ],
    );
  }

  Widget buildSubmit() {
    return buildTheme3Btn(
      onTap: () {
        controller.create();
      },
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.h),
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocaleKeys.create.tv(
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          16.horizontalSpace,
          Assets.imagesIcGem.iv(width: 20.w),
          3.horizontalSpace,
          Obx(() {
            final count = controller.count.value;
            final price = count == 1
                ? 20
                : count == 2
                ? 30
                : count == 3
                ? 50
                : count == 4
                ? 70
                : 0;
            controller.price = price;
            return price.tv(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            );
          }),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22.r)),
        gradient: LinearGradient(
          colors: [Color(0xffFBF05D), Color(0xffFDF996)],
        ),
      ),
    );
  }
}
