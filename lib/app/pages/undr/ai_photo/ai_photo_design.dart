import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/home_top_entries.dart';
import 'package:novatalk/generated/locales.g.dart';

const aiPhotoAccent = Color(0xFFFF96F7);
const aiPhotoAccentLight = Color(0xFFFFDFFD);
const aiPhotoPanel = Color(0x1AFF96F7);

class AiPhotoHomeHeader extends StatelessWidget {
  const AiPhotoHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 7.h),
      child: const Align(alignment: Alignment.centerLeft, child: HomeGemPill()),
    );
  }
}

class AiPhotoModeTabs extends StatelessWidget {
  const AiPhotoModeTabs({
    super.key,
    required this.isImageSelected,
    required this.onImageSelected,
  });

  final bool isImageSelected;
  final ValueChanged<bool> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.h,
      child: Row(
        children: [
          16.horizontalSpace,
          _AiPhotoModeTab(
            title: LocaleKeys.iToVideo.tr,
            isSelected: !isImageSelected,
            onTap: () => onImageSelected(false),
          ),
          40.horizontalSpace,
          _AiPhotoModeTab(
            title: LocaleKeys.image.tr,
            isSelected: isImageSelected,
            onTap: () => onImageSelected(true),
          ),
        ],
      ),
    );
  }
}

class _AiPhotoModeTab extends StatelessWidget {
  const _AiPhotoModeTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: isSelected ? 1 : 0.70),
        fontSize: isSelected ? 16.sp : 14.sp,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    return TapBox(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned(
              left: 0,
              bottom: 1.h,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  gradient: const LinearGradient(
                    colors: [aiPhotoAccent, Color(0x00FF96F7)],
                  ),
                ),
              ),
            ),
          text,
        ],
      ),
    );
  }
}

class AiPhotoStandaloneHeader extends StatelessWidget {
  const AiPhotoStandaloneHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
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
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildAiPhotoBodyTitle(String title) {
  return Text(
    title,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget buildAiPhotoHintList(List<String> localeKeys) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    child: DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final key in localeKeys)
            Text(key.tr, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

Widget buildAiPhotoActionButton({
  String? title,
  Widget? titleWidget,
  VoidCallback? onTap,
  bool outlined = false,
  double? width,
}) {
  return TapBox(
    onTap: onTap,
    child: Container(
      width: width ?? 250.w,
      constraints: BoxConstraints(minHeight: 44.h),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(24.r),
        border: outlined
            ? Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1)
            : null,
        gradient: outlined
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [aiPhotoAccentLight, aiPhotoAccent],
              ),
      ),
      child:
          titleWidget ??
          Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outlined ? Colors.white : Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
    ),
  );
}

class AiPhotoBottomActionPanel extends StatelessWidget {
  const AiPhotoBottomActionPanel({
    super.key,
    required this.homeReuse,
    required this.child,
  });

  final bool homeReuse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 10.h, bottom: bottom + 40.h),
      color: Colors.black,
      child: Center(child: child),
    );
  }
}

Widget buildAiPhotoBalanceText({required int balance, required String unit}) {
  return Text.rich(
    TextSpan(
      text: '${LocaleKeys.credits.tr}: ',
      children: [
        TextSpan(
          text: '$balance',
          style: const TextStyle(
            color: aiPhotoAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: ' ${unit.toLowerCase()}'),
      ],
    ),
    style: TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
  );
}

Widget buildAiPhotoGenerateAction({
  required int balance,
  required String unit,
  required VoidCallback onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildAiPhotoBalanceText(balance: balance, unit: unit),
      4.verticalSpace,
      buildAiPhotoActionButton(title: LocaleKeys.generate.tr, onTap: onTap),
    ],
  );
}

double aiPhotoBottomButtonOffset({
  required BuildContext context,
  required bool homeReuse,
}) {
  final bottom = MediaQuery.of(context).padding.bottom;
  return bottom + 40.h;
}
