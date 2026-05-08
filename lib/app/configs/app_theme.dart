import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../generated/assets.dart';
import '../../generated/locales.g.dart';
import '../utils/app_user.dart';
import '../utils/common_utils.dart';
import '../widgets/custom_Indicator.dart';
import 'constans.dart';

TextTheme get tTheme => Theme.of(Get.context!).textTheme;

ColorScheme get cTheme => Theme.of(Get.context!).colorScheme;

class Theme1 {
  Theme1._();

  static final _textTheme = TextTheme(
    labelSmall: _style.copyWith(fontSize: 9.sp, fontWeight: FontWeight.w500),
    labelMedium: _style.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w500),
    labelLarge: _style.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w700),
    bodySmall: _style.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500),
    bodyMedium: _style.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w700),
    bodyLarge: _style.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500),
    titleSmall: _style.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w700),
    titleMedium: _style.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w500),
    titleLarge: _style.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
    headlineSmall: _style.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: _style.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: _style.copyWith(
      fontSize: 24.sp,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: _style.copyWith(fontSize: 28.sp, fontWeight: FontWeight.w700),
    displayMedium: _style.copyWith(
      fontSize: 32.sp,
      fontWeight: FontWeight.w400,
    ),
    displayLarge: _style.copyWith(fontSize: 32.sp, fontWeight: FontWeight.w700),
  );
  static final _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: primary.withValues(alpha: 0.8),
    secondary: primary.withValues(alpha: 0.5),
    onSecondary: primary.withValues(alpha: 0.2),
    secondaryFixed: primary.withValues(alpha: 0.1),
    error: Color(0xffF04A4C),
    primaryFixed: Colors.black,
    primaryFixedDim: Color(0x668EF8E7),
    onError: Colors.red,
    surface: Colors.white,
    onSurface: Color(0xff727374),
    shadow: Color(0xff98E64A),
    scrim: Color(0xffFBF05D),
    tertiary: Color(0xffE0FFFA),
  );

  static ThemeData lightTheme = ThemeData(
    textTheme: _textTheme,
    colorScheme: _colorScheme,
    brightness: Brightness.dark,
    fontFamily: 'Chillax',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      scrolledUnderElevation: 0.0,
      elevation: 0,
    ),
  );

  static Color primary = Color(0xffFF96F7);
  static Color primary2 = Color(0xffFFEFB4);
  static Color cursorColor = Colors.white;
  static const List<Color> gradients = [Color(0xffFF4FAB), Color(0xffFF78D2)];
  static const List<Color> gradients2 = [
    Color(0xFF8EF8E7),
    Color(0xFFDDE7FF),
    Color(0xFFC2B6FF),
  ];
  static final themeLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cTheme.primary,
      cTheme.primary.withValues(alpha: 0.01),
      cTheme.primary,
    ],
  );
  static final List<Color> gradients3 = [
    primary.withValues(alpha: 0.3),
    primary,
  ];

  static final _style = TextStyle(color: Colors.white);
}

Widget buildDefaultBg({
  Widget? child,
  bool isExtend = true,
  BorderRadiusGeometry? borderRadius,
  EdgeInsetsGeometry? margin,
  Color? bgColor,
}) {
  return Container(
    color: bgColor ?? cTheme.primaryFixed,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Assets.imagesBgCommon.iv(
          width: Get.width,
          height: Get.height / 2.8,
          fit: BoxFit.fill,
        ),
        child ?? SizedBox.shrink(),
      ],
    ),
  );
}

Widget buildTheme1SheetRootWidget({
  Widget? child,
  bool showClose = true,
  Function? onClose,
  Color? bgColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showClose)
        TapBox(
          onTap:
              onClose ??
              () {
                Get.closeBottomSheet();
              },
          padding: EdgeInsets.all(3.r),
          child: Assets.imagesPhSheetClose.iv(width: 24.w),
        ).marginOnly(bottom: 5.h),
      Container(
        margin: EdgeInsets.only(bottom: 30.h),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.r)),
        ),
        child: child,
      ),
    ],
  ).marginSymmetric(horizontal: 18.w);
}

Widget buildTheme2SheetRootWidget({Widget? child}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(topRight: Radius.circular(24.r)),
    ),
    child: child,
  );
}

Future showTheme1Sheet({
  String? title,
  String? message,
  Widget? child,
  String? confirmText,
  Function? onConfirm,
  bool showCancel = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  child ??= message
      .tv(
        textAlign: TextAlign.center,
        style: tTheme.titleMedium!.copyWith(color: Colors.black),
      )
      .marginSymmetric(horizontal: 30.w, vertical: 20.h);

  return Get.bottomSheet(
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    buildTheme1SheetRootWidget(
      child: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              title
                  .tv(style: tTheme.titleLarge!.copyWith(color: Colors.white))
                  .marginSymmetric(vertical: 20.h),
            child,
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onConfirm != null)
                    buildTheme3Btn(
                      alignment: Alignment.center,
                      title: confirmText,
                      onTap: onConfirm,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(22.r)),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ).marginSymmetric(vertical: 15.h),
                  if (showCancel)
                    buildTheme3Btn(
                      alignment: Alignment.center,
                      title: LocaleKeys.cancelAct.tr,
                      onTap: () {
                        Get.closeBottomSheet();
                      },
                    ).marginOnly(bottom: 25.h),
                ],
              ).marginSymmetric(horizontal: 16.w),
            ),
          ],
        ),
      ),
    ),
  );
}

Future sheetActions(Map<String, Function> actions) async {
  return Get.dialog(
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.closeDialog();
                      entry.value.call();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(17.0),
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                ],
              );
            }).toList(),
          ),
        ).marginSymmetric(horizontal: 40.w),
        const SizedBox(height: 30),
        TapBox(
          onTap: () {
            Get.closeDialog();
          },
          child: buildCloseIcon(),
        ),
      ],
    ),
  );
}

class Theme1Dialog {
  Theme1Dialog._();

  static Future showGroup({Widget? child, double? minHeight}) {
    return Get.dialog(
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          constraints: BoxConstraints(minHeight: minHeight ?? 120.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }

  static Future showBottomOnlyBtn(
    Widget child, {
    String? confirmText,
    onTap,
    double? minHeight,
  }) {
    return showGroup(
      minHeight: minHeight,
      child: Stack(
        children: [
          child.marginOnly(top: 40.h, left: 20.w, right: 20.w),
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: buildTheme3Btn(
              alignment: Alignment.center,
              onTap: onTap,
              title: confirmText ?? LocaleKeys.confirmSel,
            ),
          ),
        ],
      ),
    );
  }

  static Future showBottomTwoBtn({
    String? title,
    Widget? titleWidget,
    Widget? contentWidget,
    String? content,
    String? confirmText,
    Widget? confirmWidget,
    String? cancelText,
    onConfirm,
    onCancel,
  }) {
    return showGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          20.verticalSpace,
          (titleWidget ??
                  (title ?? LocaleKeys.prompt.tr).tv(
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ))
              .marginOnly(bottom: 24.h),
          (contentWidget ??
              (content != null
                  ? content.tv(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : sh)),
          20.verticalSpace,
          buildTheme2BottomBtn(
            doneTitle: LocaleKeys.confirmSel.tr,
            done: () {
              onConfirm?.call();
            },
            cancel: () {
              Get.closeDialog();
            },
          ),
          20.verticalSpace,
        ],
      ).paddingSymmetric(horizontal: 20.w),
    );
  }
}

Widget buildTheme2Btn({
  Widget? child,
  String? title,
  onTap,
  bool isDisable = true,
}) {
  return TapBox(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24.r)),
        color: isDisable
            ? Color(0xffFF96CB)
            : Color(0xffFF96CB).withValues(alpha: 0.3),
      ),
      child:
          child ??
          (title ?? LocaleKeys.confirmSel).tv(
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
    ),
  );
}

Widget buildTheme3Btn({
  String? title,
  Widget? titleWidget,
  Alignment? alignment,
  double? vertical,
  double? horizontal,
  double? width,
  EdgeInsetsGeometry? margin,
  Function? onTap,
  bool isValid = true,
  BoxDecoration? decoration,
  bool bold = false,
}) {
  return TapBox(
    onTap: isValid ? onTap : null,
    child: Opacity(
      opacity: isValid ? 1 : 0.6,
      child: Container(
        width: width,
        alignment: alignment,
        margin: margin,
        padding: EdgeInsets.symmetric(
          vertical: vertical ?? 9.h,
          horizontal: horizontal ?? 28.w,
        ),
        decoration:
            decoration ??
            BoxDecoration(
              color: cTheme.scrim,
              borderRadius: BorderRadius.circular(22.r),
            ),
        child:
            titleWidget ??
            title.tv(
              style: tTheme.titleMedium!.copyWith(
                color: Colors.black,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
      ),
    ),
  );
}

Widget buildHomeAppBar({
  double? width,
  List<Widget>? actions,
  Widget? leading,
  Widget? title,
}) {
  return AppBar(
    centerTitle: true,
    scrolledUnderElevation: 0,
    title: title,
    actions: actions,
    leading:
        leading ??
        TapBox(
          onTap: () {
            Get.back();
          },
          child: buildBackIcon(),
        ),
  );
}

Widget buildGemWidget() {
  return Obx(
    () => TapBox(
      onTap: () {
        pushGem(ConsumeFrom.home);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: cTheme.scrim.withValues(alpha: 0.25),
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.h),
          child: Row(
            children: [
              Assets.imagesIcGem.iv(width: 20.w),
              4.horizontalSpace,
              AppUser.inst.balance.value.tv(
                style: tTheme.bodySmall?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildHomeTabBar({
  required List<Widget> tabs,
  Function(int)? onTap,
  isScrollable = true,
  tabAlignment = TabAlignment.start,
  TextStyle? unselectedLabelStyle,
  TextStyle? labelStyle,
  Offset? kOffset,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? labelPadding,
}) {
  return Container(
    height: 35.h,
    alignment: Alignment.centerLeft,
    child: TabBar(
      tabAlignment: tabAlignment,
      isScrollable: isScrollable,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w),
      labelPadding: labelPadding,
      unselectedLabelStyle:
          unselectedLabelStyle ??
          tTheme.titleMedium?.copyWith(
            color: Colors.black.withValues(alpha: 0.7),
          ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: RectDecoration(
        backgroundColor: cTheme.scrim,
        alignment: Alignment.bottomLeft,
        width: 16.w,
        height: 8.h,
        offset: kOffset ?? Offset(0, -8.h),
      ),
      dividerHeight: 0,
      labelStyle:
          labelStyle ?? tTheme.titleMedium?.copyWith(color: Colors.black),
      onTap: onTap,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      tabs: tabs,
    ),
  );
}

Widget buildHomeTitleTabBar({
  required List<Widget> tabs,
  Function(int)? onTap,
  isScrollable = true,
  tabAlignment = TabAlignment.start,
  TextStyle? unselectedLabelStyle,
  TextStyle? labelStyle,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? labelPadding,
}) {
  final ImageProvider provider = AssetImage(Assets.imagesPhEle);
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);
  return Container(
    height: 45.h,
    alignment: Alignment.centerLeft,
    child: FutureBuilder<ImageInfo>(
      future: stream.waitingResolve(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return TabBar(
          tabAlignment: tabAlignment,
          isScrollable: isScrollable,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w),
          labelPadding: labelPadding,
          unselectedLabelStyle:
              unselectedLabelStyle ??
              tTheme.headlineMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.5),
              ),
          labelStyle:
              labelStyle ??
              tTheme.headlineMedium?.copyWith(color: Colors.black),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: ImageDecoration(
            offset: Offset(12.w, -3.h),
            image: snapshot.data?.image,
            width: 62.w,
            height: 32.h,
            alignment: Alignment.bottomRight,
          ),
          dividerHeight: 0,
          onTap: onTap,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          tabs: tabs,
        );
      },
    ),
  );
}

Widget buildBackIcon({Color? color}) {
  return Center(
    child: Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF131711).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.70),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.20),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(Icons.arrow_back_ios_rounded,color: color,size: 16.w,),
    ),
  );
}

Widget buildCloseIcon({Color? color}) {
  return Center(
    child: Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF131711).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.70),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.20),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(Icons.close,color: color,size: 16.w,),
    ),
  );
}
