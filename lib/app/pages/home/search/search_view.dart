import 'package:novatalk/generated/locales.g.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../generated/assets.dart';
import '../../../widgets/gradient_bound_painter.dart';
import '../home_controller.dart';
import '../home_view.dart';
import 'search_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends GetBuildView<SearchController> {
  const SearchView({super.key});

  @override
  Widget builder(BuildContext context) {
    return ReleaseTextEditFocus(
      child: Scaffold(
        body: buildDefaultBg(
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        12.horizontalSpace,
                        // TapBox(
                        //   onTap: () => Get.back(),
                        //   padding: EdgeInsets.all(5.r),
                        //   child: buildBackIcon(),
                        // ).marginOnly(left: 13.w),
                        // 5.horizontalSpace,
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  offset: Offset(0, 0),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: buildTopSearchTextField(
                              isSearch: true,
                              controller: controller.searchController,
                              onSubmitted: controller.onSubmitted,
                            ),
                          ).marginOnly(right: 12.w),
                        ),
                      ],
                    ),
                    16.verticalSpace,
                    Expanded(
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: SearchRoleContentWidget(
                          type: DiscoverListType.all,
                          firstLoad: false,
                          controller: controller.roleContentController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchRoleContentWidget extends RoleContentWidget {
  const SearchRoleContentWidget({
    super.key,
    required super.type,
    super.fromCreate = false,
    super.firstLoad = true,
    super.byHome = false,
    super.controller,
  });

  @override
  RoleContentWidgetState createState() => _SearchRoleContentWidgetState();
}

class _SearchRoleContentWidgetState extends RoleContentWidgetState {
  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller.easyRefreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoadMore,
      child: Obx(() {
        if (controller.pageData.isEmpty &&
            controller.isLoading.value == false) {
          return Center(child: buildEmpty().marginOnly(bottom: 200.h));
        }
        if (widget.fromCreate) {
          return sh;
        }
        return buildContent();
      }),
    );
  }

  @override
  Widget buildContent() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return 12.verticalSpace;
      },
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: controller.pageData.length,
      itemBuilder: (BuildContext context, int index) {
        final item = controller.pageData[index];
        return TapBox(
          onTap: () {
            logic.onItemTap(item, widget.type);
          },
          child: smallRoleItem(index),
        );
      },
    );
  }

  Widget smallRoleItem(int index) {
    final item = controller.pageData[index];
    final vip = item.vip == true;
    final strokeWidth = vip ? 1.0 : 0.0;
    final radius = 16.r;

    return Padding(
      padding: EdgeInsets.all(strokeWidth),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: vip
              ? Theme1.primary.withValues(alpha: 0.2)
              : Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 35.h),
              padding: EdgeInsets.only(
                left: 122.w,
                right: 12.h,
                top: 12.h,
                bottom: 12.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 0),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: Get.width / 3),
                        child: item.name.tv(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (!item.age.isVoid)
                        Container(
                          margin: EdgeInsets.only(left: 5.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: item.age.tv(
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: cTheme.primary,
                            ),
                          ),
                        ),
                      ex,
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 9.w,
                        ),
                        decoration: BoxDecoration(
                          color: cTheme.scrim,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: LocaleKeys.chat.tv(
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.tags != null || item.tags?.isNotEmpty == true)
                    buildTags(item),
                  3.verticalSpace,
                  (item.intro ?? item.aboutMe)
                      .tv(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                      .marginOnly(right: 15.w),
                ],
              ),
            ),
            Container(
              width: 100.w,
              height: 100.w,
              margin: EdgeInsets.only(left: 8.w),
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipOval(child: item.avatar.iv(fit: BoxFit.cover)),
                  ),
                  Positioned(
                    bottom: -8.h,
                    child: FavoredButton(
                      onCollect: (role) {
                        controller.onCollect(role);
                      },
                      role: item,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
