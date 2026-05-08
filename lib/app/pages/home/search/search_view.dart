import 'package:easy_refresh/easy_refresh.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/app/widgets/release_text_edit_focus.dart';

import '../../../../generated/assets.dart';
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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 1.h),
                child: Row(
                  children: [
                    TapBox(
                      onTap: Get.back,
                      child: buildBackIcon(color: Colors.white),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: _SearchInput(
                        controller: controller.searchController,
                        onSubmitted: controller.onSubmitted,
                      ),
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Expanded(
                child: SearchRoleContentWidget(
                  type: DiscoverListType.all,
                  firstLoad: false,
                  controller: controller.roleContentController,
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
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: controller.pageData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 224.h,
        crossAxisSpacing: 7.w,
        mainAxisSpacing: 7.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        final item = controller.pageData[index];
        return HomeRoleGridCard(
          role: item,
          onTap: () {
            logic.onItemTap(item, widget.type);
          },
          onCollect: controller.onCollect,
          likeTop: 8.h,
          likeRight: 6.w,
        );
      },
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final void Function(String value) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22.r),
      borderSide: BorderSide.none,
    );
    return SizedBox(
      height: 44.h,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF331E31),
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.30),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.zero,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border,
          border: border,
          prefixIconConstraints: BoxConstraints(
            minWidth: 38.w,
            minHeight: 44.h,
          ),
          prefixIcon: SizedBox.square(
            dimension: 30.w,
            child: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 4.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: 0.70,
                  child: Assets.imagesIcSearch.iv(width: 23.w),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
