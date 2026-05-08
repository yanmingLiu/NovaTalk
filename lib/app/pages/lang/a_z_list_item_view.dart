import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/assets.dart';

class AzListItemView extends StatelessWidget {
  const AzListItemView({
    super.key,
    required this.name,
    this.isShowSeparator = false,
    this.onTap,
    this.isChoosed = false,
  });

  final String name;

  final bool isShowSeparator;
  final bool isChoosed;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          border: isShowSeparator
              ? Border(bottom: BorderSide(color: Colors.grey[300]!, width: 0.5))
              : null,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isChoosed)
              SizedBox(
                width: 36.w,
                height: 40.h,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: SvgPicture.asset(
                      Assets.imagesIcLangCheck,
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                ),
              ),
            // else
            //   Assets.imagesIgCheck2Un.iv(width: 20.w),
          ],
        ),
      ),
    );
  }
}
