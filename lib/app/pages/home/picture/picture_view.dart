import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/constans.dart';
import 'package:novatalk/app/entities/create_style_bean.dart';
import 'package:novatalk/app/routes/app_pages.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';
import 'package:novatalk/generated/assets.dart';
import 'package:novatalk/generated/locales.g.dart';

import 'picture_controller.dart';

const _pictureAccent = Color(0xFFFF96F7);
const _pictureAccentLight = Color(0xFFFFDFFD);
const _pictureClearIcon = 'library/images/ic_picture_clear.webp';
const _pictureCreationsIcon = 'library/images/ic_picture_c.webp';

Color get _picturePanel => Colors.white.withValues(alpha: 0.10);

class PictureView extends GetView<PictureController> {
  const PictureView({super.key});

  @override
  Widget build(BuildContext context) {
    return ReleaseTextEditFocus(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const _PictureTopGlow(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 20.h,
                            bottom:
                                MediaQuery.paddingOf(context).bottom + 150.h,
                          ),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDescription(),
                              20.verticalSpace,
                              _PictureThemeSection(controller: controller),
                              20.verticalSpace,
                              _buildCount(),
                              20.verticalSpace,
                              _buildRatio(),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: MediaQuery.paddingOf(context).bottom + 40.h,
                          child: Center(child: _buildSubmit()),
                        ),
                        Obx(
                          () => controller.generating.value
                              ? buildProcessView()
                              : sh,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 7.h),
        child: Row(
          children: [
            TapBox(
              onTap: () => pushGem(ConsumeFrom.home),
              child: Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: _picturePanel,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.imagesIcGem.iv(width: 20.w, height: 20.w),
                    4.horizontalSpace,
                    Obx(
                      () => AppUser.inst.balance.value.tv(
                        style: TextStyle(
                          color: const Color(0xFFC7ABFF),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            TapBox(
              onTap: () {
                Get.toNamed(Routes.CREATIONS);
              },
              child: Container(
                width: 102.w,
                height: 32.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _picturePanel,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pictureCreationsIcon.iv(
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.contain,
                    ),
                    4.horizontalSpace,
                    LocaleKeys.creations.tr.tv(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFF5F5F5),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      height: 172.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: _picturePanel,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 24.h,
            child: Row(
              children: [
                LocaleKeys.inputDescription.tr.tv(
                  style: TextStyle(
                    color: const Color(0xFFF5F5F5),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TapBox(
                  onTap: controller.clearPrompt,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Center(
                      child: _pictureClearIcon.iv(
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          8.verticalSpace,
          Container(
            height: 84.h,
            decoration: BoxDecoration(
              color: _picturePanel,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: RawScrollbar(
              controller: controller.scrollController,
              thumbVisibility: true,
              thickness: 3.w,
              radius: Radius.circular(2.r),
              thumbColor: Colors.white.withValues(alpha: 0.25),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Obx(
                () => TextField(
                  scrollController: controller.scrollController,
                  controller: controller.promptTextController,
                  cursorColor: _pictureAccent,
                  maxLength: 500,
                  minLines: 4,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  buildCounter:
                      (
                        BuildContext context, {
                        int? currentLength,
                        int? maxLength,
                        bool? isFocused,
                      }) {
                        return const SizedBox.shrink();
                      },
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
                    border: InputBorder.none,
                    hintText: controller.initPrompt.value,
                    hintMaxLines: 4,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.30),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          8.verticalSpace,
          SizedBox(
            height: 24.h,
            child: Row(
              children: [
                TapBox(
                  onTap: controller.aiWrite,
                  child: Container(
                    height: 24.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_pictureAccentLight, _pictureAccent],
                      ),
                    ),
                    child: LocaleKeys.aiWrite.tr.tv(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.promptTextController,
                  builder: (context, value, child) {
                    return '${value.text.length}/500'.tv(
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCount() {
    return Row(
      children: [
        LocaleKeys.numImages.tr.tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Obx(() {
          final count = controller.count.value;
          return Container(
            width: 120.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: _picturePanel,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                _PictureStepButton(
                  icon: _PictureStepIcon.minus,
                  enabled: count > 1,
                  onTap: () {
                    if (controller.count.value > 1) {
                      controller.count.value--;
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: count.tv(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _PictureStepButton(
                  icon: _PictureStepIcon.plus,
                  enabled: count < 4,
                  onTap: () {
                    if (controller.count.value < 4) {
                      controller.count.value++;
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRatio() {
    final ratios = [
      _PictureRatioData(
        value: '1:1',
        title: LocaleKeys.square,
        iconWidth: 14.w,
        iconHeight: 14.w,
      ),
      _PictureRatioData(
        value: '9:16',
        title: LocaleKeys.igStore,
        iconWidth: 12.w,
        iconHeight: 15.h,
      ),
      _PictureRatioData(
        value: '9:19',
        title: LocaleKeys.igFullscreen,
        iconWidth: 11.w,
        iconHeight: 15.h,
      ),
      _PictureRatioData(
        value: '4:3',
        title: LocaleKeys.socialMedia,
        iconWidth: 13.w,
        iconHeight: 15.h,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocaleKeys.imageRatio.tr.tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.verticalSpace,
        Obx(() {
          controller.ratio.value;
          return Row(
            children: List.generate(ratios.length, (index) {
              final ratio = ratios[index];
              final selected = controller.ratio.value == ratio.value;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == ratios.length - 1 ? 0 : 5.w,
                ),
                child: TapBox(
                  onTap: () {
                    controller.ratio.value = ratio.value;
                  },
                  child: _PictureRatioItem(data: ratio, selected: selected),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildSubmit() {
    return TapBox(
      onTap: controller.create,
      child: Container(
        width: 250.w,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pictureAccentLight, _pictureAccent],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocaleKeys.create.tr.tv(
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            5.horizontalSpace,
            Assets.imagesIcGem.iv(width: 20.w, height: 20.w),
            2.horizontalSpace,
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
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PictureTopGlow extends StatelessWidget {
  const _PictureTopGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 300.h,
        width: double.infinity,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.40,
              child: Assets.imagesBgCommon.iv(
                width: Get.width,
                height: 210.h,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 120.h,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0), Colors.black],
                    stops: const [0.05, 0.60],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PictureThemeSection extends StatefulWidget {
  const _PictureThemeSection({required this.controller});

  final PictureController controller;

  @override
  State<_PictureThemeSection> createState() => _PictureThemeSectionState();
}

class _PictureThemeSectionState extends State<_PictureThemeSection> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final styles = widget.controller.styleList;
      final real = <CreateStyleBean>[];
      final fantasy = <CreateStyleBean>[];
      for (final style in styles) {
        if (style.styleType == 0) {
          real.add(style);
        } else {
          fantasy.add(style);
        }
      }
      final currentStyles = _index == 0 ? real : fantasy;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TapBox(
                onTap: () => setState(() => _index = 0),
                child: _PictureTabLabel(
                  title: LocaleKeys.real.tr,
                  selected: _index == 0,
                ),
              ),
              40.horizontalSpace,
              TapBox(
                onTap: () => setState(() => _index = 1),
                child: _PictureTabLabel(
                  title: LocaleKeys.fantasy.tr,
                  selected: _index == 1,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          SizedBox(
            height: 79.h,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: currentStyles.length,
              separatorBuilder: (context, index) => 12.horizontalSpace,
              itemBuilder: (context, index) {
                final style = currentStyles[index];
                final selected = identical(
                  widget.controller.selectedStyle,
                  style,
                );
                return TapBox(
                  onTap: () {
                    widget.controller.selectStyle(style);
                  },
                  child: _PictureStyleItem(style: style, selected: selected),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _PictureTabLabel extends StatelessWidget {
  const _PictureTabLabel({required this.title, required this.selected});

  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (selected)
          Positioned(
            left: 0,
            bottom: 1.h,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                gradient: LinearGradient(
                  colors: [_pictureAccent, _pictureAccent.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        title.tv(
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.70),
            fontSize: selected ? 16.sp : 14.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PictureStyleItem extends StatelessWidget {
  const _PictureStyleItem({required this.style, required this.selected});

  final CreateStyleBean style;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: style.cover.iv(
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                  ),
                ),
                if (selected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _pictureAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: _pictureAccent, width: 1.w),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          4.verticalSpace,
          style.name.tv(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? _pictureAccent
                  : Colors.white.withValues(alpha: 0.70),
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PictureStepIcon { minus, plus }

class _PictureStepButton extends StatelessWidget {
  const _PictureStepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final _PictureStepIcon icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.30,
      child: TapBox(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: Center(
            child: CustomPaint(
              size: Size(9.w, 9.w),
              painter: _PictureStepPainter(icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _PictureStepPainter extends CustomPainter {
  const _PictureStepPainter(this.icon);

  final _PictureStepIcon icon;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
    if (icon == _PictureStepIcon.plus) {
      final centerX = size.width / 2;
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PictureStepPainter oldDelegate) {
    return oldDelegate.icon != icon;
  }
}

class _PictureRatioData {
  const _PictureRatioData({
    required this.value,
    required this.title,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String value;
  final String title;
  final double iconWidth;
  final double iconHeight;
}

class _PictureRatioItem extends StatelessWidget {
  const _PictureRatioItem({required this.data, required this.selected});

  final _PictureRatioData data;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82.w,
      child: Column(
        children: [
          Container(
            height: 32.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? _pictureAccent.withValues(alpha: 0.12)
                  : _picturePanel,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? _pictureAccent : Colors.transparent,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: Center(
                    child: Container(
                      width: data.iconWidth,
                      height: data.iconHeight,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE6E6E6),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
                8.horizontalSpace,
                data.value
                    .replaceAll(':', ' : ')
                    .tv(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
          4.verticalSpace,
          data.title.tr.tv(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? _pictureAccent
                  : Colors.white.withValues(alpha: 0.70),
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
