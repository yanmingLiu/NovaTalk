import 'dart:math';
import 'dart:ui';

import 'package:novatalk/app/pages/home/picture/picture_view.dart';
import 'package:flutter/services.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/pages/chat/chat_controller.dart';
import 'package:novatalk/app/pages/chat/chat_view.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/log/log_event.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/app/widgets/home_top_entries.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../generated/assets.dart';
import '../../configs/app_config.dart';
import '../../configs/constans.dart';
import '../../routes/app_pages.dart';
import '../../utils/clo_util.dart';
import '../../utils/common_utils.dart';
import '../../utils/device_info.dart';
import '../../widgets/gradient_bound_painter.dart';
import '../setting/setting_view.dart';
import '../undr/ai_photo/ai_photo_page.dart';
import 'home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';

part 'home_discover_view.dart';

class HomeView extends GetBuildView<HomeController> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: buildDefaultBg(
        child: IndexedStack(
          index: controller.currentTabIndex,
          children: [
            const HomeDiscoverView(),
            CloUtil.isCloB ? const AiPhotoPage() : const PictureView(),
            const ChatView(),
            const SettingView(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    BottomNavigationBarItem buildBottomNavigationBarItem(
      String icon,
      String activeIcon, {
      String? label,
    }) {
      return BottomNavigationBarItem(
        icon: icon.iv(width: 24.w),
        activeIcon: activeIcon.iv(width: 24.w),
        label: label ?? '',
      );
    }

    final msgTab = buildBottomNavigationBarItem(
      Assets.imagesPhMainMsg,
      Assets.imagesPhMainMsg2,
    );
    final discoverTab = buildBottomNavigationBarItem(
      Assets.imagesPhMainDiscover,
      Assets.imagesPhMainDiscover2,
    );
    final navigationItems = [
      discoverTab,
      buildBottomNavigationBarItem(
        Assets.imagesPhMainCreate,
        Assets.imagesPhMainCreate2,
      ),
      msgTab,
      buildBottomNavigationBarItem(
        Assets.imagesPhMainMe,
        Assets.imagesPhMainMe2,
      ),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.r),
        topRight: Radius.circular(12.r),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cTheme.primary,
        unselectedItemColor: Colors.white.withValues(alpha: 0.4),
        currentIndex: controller.currentTabIndex,
        selectedLabelStyle: tTheme.labelMedium,
        unselectedLabelStyle: tTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          DeviceInfo.getIdfa();
          controller.setCurrentTabIndex(index);
          AppUser.inst.refreshUser();
          final selectedItem = navigationItems[index];
          controller.selectedDiscover = selectedItem == discoverTab;
          if (selectedItem == msgTab) {
            $<ChatController>()?.refreshData();
          }
          // if (selectedItem.label == LocaleKeys.moment.tr) {
          //   logEvent('c_moment');
          // }
        },
        items: navigationItems,
      ),
    );
  }
}

class RoleContentWidget extends StatefulWidget {
  final DiscoverListType type;
  final bool fromCreate, firstLoad, byHome;
  final PageLoadRoleController? controller;

  const RoleContentWidget({
    super.key,
    required this.type,
    this.fromCreate = false,
    this.firstLoad = true,
    this.byHome = false,
    this.controller,
  });

  @override
  State<RoleContentWidget> createState() => RoleContentWidgetState();
}

class RoleContentWidgetState extends State<RoleContentWidget> {
  late final PageLoadRoleController controller =
      widget.controller ?? PageLoadRoleController();

  RolesController get logic => Get.find();

  @override
  void initState() {
    super.initState();
    controller.onInit(widget.type);
    WidgetsBinding.instance.addPostFrameCallback((v) {
      first();
    });

    Connectivity().onConnectivityChanged.listen((status) {
      if (status
          .where((element) => element != ConnectivityResult.none)
          .isNotEmpty) {
        if (controller.pageData.isEmpty) {
          first();
        }
      }
    });
  }

  Future<void> first() async {
    if (widget.firstLoad) {
      SmartDialog.showLoading();
      await controller.onRefresh();
      SmartDialog.dismiss();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller.easyRefreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoadMore,
      child: Obx(() {
        if (controller.pageData.isEmpty &&
            controller.isLoading.value == false) {
          return Center(child: buildEmpty());
        }
        if (widget.fromCreate) {
          return sh;
        }
        return buildContent();
      }),
    );
  }

  Widget buildContent() {
    return Obx(() {
      // AdLoader().nativeAdUtil.adNativeLoaded.value;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 7.w,
          mainAxisSpacing: 7.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: controller.pageData.length,
        itemBuilder: (BuildContext context, int index) {
          final item = controller.pageData[index];
          // final bool showAd =
          //     widget.type == DiscoverListType.all &&
          //     AdLoader().nativeAd != null &&
          //     AppUser.inst.isVip.value == false;
          //
          // if (showAd && index == 2) {
          //   return Container(
          //     constraints: const BoxConstraints(minWidth: 168, minHeight: 260),
          //     child: Material(
          //       elevation: 0,
          //       child: Stack(
          //         children: [
          //           // AdWidget(ad: AdLoader().nativeAd!),
          //           Container(
          //             padding: EdgeInsets.symmetric(
          //               horizontal: 5.w,
          //               vertical: 1.h,
          //             ),
          //             decoration: BoxDecoration(
          //               color: Theme1.primary,
          //               borderRadius: BorderRadius.circular(4.r),
          //             ),
          //             child: "AD".tv(),
          //           ),
          //         ],
          //       ),
          //     ),
          //   );
          // }
          return RoleItem(
            role: item,
            onTap: (role) {
              logic.onItemTap(role, widget.type);
            },
            index: index,
          );
        },
      );
    });
  }
}

Widget buildEmpty() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Assets.imagesPhDataEmpty.iv(height: 180.w),
      LocaleKeys.noData.tv(
        style: tTheme.titleMedium?.copyWith(
          color: Colors.black.withValues(alpha: 0.75),
        ),
      ),
    ],
  );
}

class RoleItem extends StatelessWidget {
  const RoleItem({super.key, required this.role, this.onTap, this.index = 0});

  final RoleRecords role;
  final int index;
  final Function(RoleRecords role)? onTap;

  @override
  Widget build(BuildContext context) {
    final tags = role.tags;
    List<String> result = (tags != null && tags.length > 3)
        ? tags.take(3).toList()
        : tags ?? [];
    result = insertHotTag(role.tagType, result);
    final strokeWidth = role.vip == true ? 1.5.w : 0.0;
    final radius = 16.r;
    return InkWell(
      onTap: () => onTap?.call(role),
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: GradientBoundPainter(
          radius: radius,
          strokeWidth: strokeWidth,
          borderGradient: Theme1.themeLinearGradient,
        ),
        child: Container(
          padding: EdgeInsets.all(strokeWidth),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xff1B1B26),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: role.avatar.iv(),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 1],
                        colors: [
                          Color(0xB3101010),
                          Colors.transparent,
                          Color(0xFF111111),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          2.horizontalSpace,
                          Flexible(
                            child: role.name.tv(
                              style: tTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (role.age != null)
                            Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.symmetric(
                                vertical: 1.h,
                                horizontal: 5.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: Colors.black.withValues(alpha: 0.4),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.w,
                                ),
                              ),
                              child: role.age.tv(
                                style: tTheme.labelMedium?.copyWith(
                                  color: cTheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      4.verticalSpace,
                      if (result.isNotEmpty && CloUtil.isCloB) buildTags(role),
                      4.verticalSpace,
                      (role.intro ?? role.aboutMe).tv(
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ).paddingAll(8.r),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: FavoredButton(role: role),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<String> insertHotTag(String? tagType, List<String> result) {
  final kNS = AppConfig.kNS;
  final kBD = AppConfig.kBD;
  if ((tagType?.contains(kNS) ?? false) && !result.contains(kNS)) {
    result.insert(0, kNS);
  }
  if ((tagType?.contains(kBD) ?? false) && !result.contains(kBD)) {
    result.insert(0, kBD);
  }
  return result;
}

Widget buildTags(RoleRecords role) {
  final tags = role.tags;
  List<String> result = (tags != null && tags.length > 3)
      ? tags.take(3).toList()
      : tags ?? [];
  result = insertHotTag(role.tagType, result);

  return ClipRRect(
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: List.generate(min(result.length, 3), (index) {
        final Widget child;
        if (index > 2) {
          child = Icon(Icons.more_horiz, size: 16.r, color: Colors.white);
        } else {
          child = Builder(
            builder: (ctx) {
              final text = result[index];
              return buildRoleTagsWidget(text: text);
            },
          );
        }
        return child;
      }),
    ).marginSymmetric(vertical: 5.h),
  );
}

Widget buildRoleTagsWidget({String? text, Widget? textWidget}) {
  return Container(
    margin: EdgeInsets.only(right: 4.w),
    decoration: BoxDecoration(
      color: Color(0xffE9EAEE).withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(25.r),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child:
          textWidget ??
          text.tv(style: tTheme.labelSmall?.copyWith(color: Colors.black)),
    ),
  );
}

class FavoredButton extends StatelessWidget {
  const FavoredButton({
    super.key,
    required this.role,
    this.onCollect,
    this.padding,
  });

  final RoleRecords role;
  final void Function(RoleRecords role)? onCollect;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    bool isCollect = role.collect ?? false;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        '${role.likes ?? 0}'.tv(style: tTheme.bodySmall),
        const SizedBox(width: 3),
        (isCollect ? Assets.imagesIcLike : Assets.imagesIcLike2).iv(
          width: 10.w,
        ),
      ],
    );

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.w,
            ),
          ),
          child: onCollect == null
              ? Padding(padding: EdgeInsets.all(3.r), child: content)
              : TapBox(
                  padding: EdgeInsets.all(3.r),
                  onTap: () {
                    onCollect?.call(role);
                  },
                  child: content,
                ),
        ),
      ),
    );
  }
}

Widget buildTopSearchTextField({
  bool enabled = true,
  bool isSearch = false,
  TextEditingController? controller,
  void Function(String value)? onSubmitted,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: BorderSide(
      color: cTheme.scrim.withValues(alpha: 0.25),
      width: 1.w,
    ),
  );
  return SizedBox(
    height: 40.h,
    child: TextField(
      enabled: enabled,
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      cursorColor: Theme1.cursorColor,
      style: tTheme.bodyLarge!.copyWith(color: Colors.black),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintStyle: tTheme.bodyLarge!.copyWith(
          color: Color(0xffBFBFBF),
          fontWeight: FontWeight.w400,
        ),
        hintText: LocaleKeys.searchByName.tr,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
        enabledBorder: border,
        disabledBorder: border,
        border: border,
        prefixIconConstraints: BoxConstraints(minWidth: 30.w),
        prefixIcon: UnconstrainedBox(
          child: Container(
            width: 22.w,
            height: 15.h,
            alignment: Alignment.centerRight,
            child: Assets.imagesIcSearch.iv(width: 13.w),
          ),
        ),
        focusedBorder: border,
      ),
    ),
  );
}
