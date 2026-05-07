import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/pages/chat/chat_controller.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/pages/chat/role_profile/role_profile_appbar.dart';
import 'package:novatalk/app/pages/home/home_controller.dart';
import 'package:novatalk/app/pages/vip/vip_view.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../../generated/assets.dart';
import '../../../configs/constans.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/storage_util.dart';
import '../../../widgets/gradient_bound_painter.dart';
import '../../call/phone_title.dart';
import '../../home/home_view.dart';

class RoleProfilePage extends StatefulWidget {
  const RoleProfilePage({super.key});

  @override
  State<RoleProfilePage> createState() => _RoleProfilePageState();
}

class _RoleProfilePageState extends State<RoleProfilePage> {
  late RoleRecords role;

  bool isLoading = false;

  bool get isCloB => CloUtil.isCloB;

  // bool get isCloB => false;

  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  final ctr = Get.find<ChatRoomController>();
  List<RoleRecordsImages> images = <RoleRecordsImages>[];

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null && arguments is RoleRecords) {
      role = arguments;
    }
    _scrollController.addListener(_onScroll);

    images = ctr.role.images ?? [];

    ever(ctr.roleImagesChanged, (_) {
      images = ctr.role.images ?? [];
      setState(() {});
    });
  }

  void _onScroll() {
    // 根据滚动的偏移量调整透明度（滚动 0 ~ 200）
    double offset = _scrollController.offset;
    final maxOffset = Get.width - kToolbarHeight;
    double opacity = (offset / maxOffset).clamp(0, 1); // 限制透明度在 0 到 1 的范围内
    setState(() {
      _appBarOpacity = opacity;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _deleteChat() async {
    Get.closeBottomSheet();
    Theme1Dialog.showBottomTwoBtn(
      content: LocaleKeys.delChatHits,
      onConfirm: () async {
        Get.closeDialog();
        var res = await ctr.deleteConv();
        if (res) {
          $<ChatController>()?.sessionListController.onRefresh();
          Get.until((route) => route.isFirst);
        }
      },
    );
  }

  void _clearHistory() async {
    Get.closeBottomSheet();
    Theme1Dialog.showBottomTwoBtn(
      content: LocaleKeys.delChatHistoryHits,
      onConfirm: () async {
        Get.closeDialog();
        var res = await ctr.resetConv();
        if (res) {
          SmartDialog.showNotify(
            msg: LocaleKeys.cleHistorySuccess.tr,
            notifyType: NotifyType.success,
          );
        } else {
          SmartDialog.showNotify(
            msg: LocaleKeys.cleHistoryFailed.tr,
            notifyType: NotifyType.failure,
          );
        }
      },
    );
  }

  Future _follow() async {
    final id = role.id;
    if (id == null) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    var chatCtrl = Get.find<ChatController>();
    chatCtrl.refreshLikedSessionList();
    var rolesCtr = Get.find<RolesController>();
    if (role.collect == true) {
      final res = await ApiSvc.cancelCollectRole(id);
      if (res) {
        role.collect = false;
        rolesCtr.followEvent.value = (FollowEvent.unfollow, id);
      }
      isLoading = false;
      setState(() {});
    } else {
      final res = await ApiSvc.collectRole(id);
      if (res) {
        role.collect = true;
        rolesCtr.followEvent.value = (FollowEvent.follow, id);
        collectShowHelpUs(role.id!);
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoleProfileAppBar(
        role: role,
        opacity: _appBarOpacity,
        onClearHistory: _clearHistory,
        onDelete: _deleteChat,
        onReport: report,
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: buildBottomNavigationBar(),
      body: buildDefaultBg(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              width: Get.width,
              height: Get.height / 2.2,
              child: role.avatar.iv(fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -50.h,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              height: 60.h,
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 20.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.r),
                                  topRight: Radius.circular(16.r),
                                ),
                                color: Colors.black.withValues(alpha: 0.4),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.w,
                                  ),
                                  right: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Assets.imagesPhPfMsg.iv(width: 16.w),
                                      10.horizontalSpace,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            role.sessionCount ?? '0',
                                            style: tTheme.bodyLarge?.copyWith(
                                              height: 1.2,
                                            ),
                                          ),
                                          Text(
                                            LocaleKeys.dialogue.tr,
                                            style: tTheme.labelMedium?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.75,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  18.horizontalSpace,
                                  Row(
                                    children: [
                                      Assets.imagesIcLike.iv(width: 16.w),
                                      10.horizontalSpace,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            role.likes ?? '0',
                                            style: tTheme.bodyLarge?.copyWith(
                                              height: 1.2,
                                            ),
                                          ),
                                          Text(
                                            LocaleKeys.favorite.tr,
                                            style: tTheme.labelMedium?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.75,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: DefaultTabController(
                          length: isCloB ? 2 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 0.51.sw,
                                          ),
                                          child: Text(
                                            role.name ?? '',
                                            style: tTheme.headlineMedium!
                                                .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 24.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        if (!role.age.isVoid)
                                          SizedBox(
                                            width: 27.w,
                                            child: buildAgeWidget(role.age),
                                          ).marginOnly(top: 3.h),
                                      ],
                                    ),
                                  ),
                                  // InkWell(
                                  //   onTap: _follow,
                                  //   child: Container(
                                  //     width: 105.w,
                                  //     padding: EdgeInsets.symmetric(
                                  //       vertical: 3.5.h,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: role.collect == true
                                  //           ? Colors.white.withOpacity(0.1)
                                  //           : Color(0xffE887E9),
                                  //       borderRadius: BorderRadius.circular(8.r),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       children: [
                                  //         isLoading
                                  //             ? const SizedBox(
                                  //                 width: 15,
                                  //                 height: 15,
                                  //                 child: CircularProgressIndicator(
                                  //                   color: Colors.white,
                                  //                   strokeWidth: 1,
                                  //                 ),
                                  //               )
                                  //             : (role.collect == true
                                  //                       ? Assets.imagesIcLike
                                  //                       : Assets.imagesIcLike2)
                                  //                   .iv(width: 20.w),
                                  //         const SizedBox(width: 8),
                                  //         Text(
                                  //           role.collect == true
                                  //               ? LocaleKeys.liked.tr
                                  //               : LocaleKeys.like.tr,
                                  //           style: tTheme.titleMedium?.copyWith(
                                  //             fontWeight: FontWeight.w500,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ).marginSymmetric(horizontal: 20.w),
                              14.verticalSpace,
                              Divider(thickness: 4.h, color: Color(0xffFAFAFA)),
                              7.verticalSpace,
                              buildTabBar(),
                              Builder(
                                builder: (context) {
                                  final controller = DefaultTabController.of(
                                    context,
                                  );
                                  return IndexedStack(
                                    index: controller.index,
                                    children: [
                                      buildInfoWidget(),
                                      _buildImages(),
                                    ],
                                  );
                                },
                              ),
                              120.verticalSpace,
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        right: 12.h,
                        top: -45.h,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cTheme.scrim,
                              width: 1.5.w,
                            ),
                          ),
                          child: ClipOval(
                            child: role.avatar.iv(
                              width: 87.w,
                              height: 87.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(top: 138.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabBar() {
    if (isCloB) {
      return Container(
        width: Get.width / 1.5,
        height: 50.h,
        margin: EdgeInsets.only(bottom: 5.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              left: -6.w,
              child: buildHomeTabBar(
                // isScrollable: false,
                tabAlignment: TabAlignment.start,
                kOffset: Offset(0, -10.h),
                labelStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.75),
                ),
                tabs: [
                  Tab(text: LocaleKeys.info.tr),
                  Tab(text: LocaleKeys.moment.tr),
                ],
                onTap: (index) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      );
    }
    return sh;
    // return SizedBox(
    //   height: 50.h,
    //   width: Get.width,
    //   child: Stack(
    //     clipBehavior: Clip.none,
    //     children: [
    //       Positioned(
    //         left: -15.w,
    //         child: buildHomeTabBar(tabs: [Tab(text: LocaleKeys.info.tr)]),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildTags() {
    if (!CloUtil.isCloB || role.tags == null || role.tags?.isEmpty == true) {
      return const SizedBox();
    }
    final tags = role.tags!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.verticalSpace,
        Text(
          LocaleKeys.tags.tr,
          style: TextStyle(
            fontSize: 16.sp,
            color: Color(0xff434343),
            fontWeight: FontWeight.w500,
          ),
        ),
        8.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: tags
              .map(
                (e) => buildRoleTagsWidget(
                  textWidget: e.tv(
                    style: tTheme.bodySmall?.copyWith(color: Color(0xff595959)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildImages() {
    if (!CloUtil.isCloB || images.isEmpty) {
      return const SizedBox();
    }
    final imageCount = images.length;
    return Obx(() {
      ctr.roleImagesChanged.value;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: Border.all(color: Color(0xffFFE588).withValues(alpha: 0.15)),
        ),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.w,
          ),
          itemCount: imageCount,
          itemBuilder: (_, idx) {
            final image = images[idx];
            final unlocked = image.unlocked ?? false;
            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
              child: SizedBox(
                height: 65.w,
                width: 65.w,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          ctr.onTapImage(image);
                        },
                        child: image.imageUrl.iv(),
                      ),
                    ),
                    if (!unlocked)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () async {
                            ctr.onTapUnlockImage(image);
                          },
                          child: Stack(
                            children: [
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Assets.imagesIcGem.iv(
                                            width: 20,
                                            height: 20,
                                          ),
                                          2.horizontalSpace,
                                          Text(
                                            '${image.gems ?? 0}',
                                            style: tTheme.bodyMedium!.copyWith(
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
          },
        ),
      );
    });
  }

  Widget buildInfoWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.profileOverview.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: Color(0xff434343),
              fontWeight: FontWeight.w500,
            ),
          ),
          8.verticalSpace,
          Text(
            role.aboutMe ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xff595959),
              fontWeight: FontWeight.w400,
            ),
          ),
          10.verticalSpace,
          _buildTags(),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return SafeArea(
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
        ),
        child: Center(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TapBox(
                    onTap: () async {
                      SmartDialog.showLoading();
                      await _follow();
                      SmartDialog.dismiss();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(22.r)),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child:
                          (role.collect == true
                                  ? LocaleKeys.followed
                                  : LocaleKeys.follow)
                              .tv(
                                style: tTheme.titleMedium!.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                    ),
                  ),
                ),
                11.horizontalSpace,
                Expanded(
                  flex: 4,
                  child: buildTheme3Btn(
                    alignment: Alignment.center,
                    title: LocaleKeys.chat.tr,
                    onTap: () {
                      Get.popTo(Routes.CHAT_ROOM);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void collectShowHelpUs(String roleId) {
  if (!StorageUtils.isLikedRole(roleId) && !StorageUtils.showedHelpUsS3) {
    StorageUtils.showedHelpUsS3 = true;
    showHelpUs();
    StorageUtils.likedRole(roleId);
  }
}

Widget buildAgeWidget(int? age) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(10.w),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.4),
        width: 1.0,
      ),
    ),
    child: Text(
      '$age',
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.sp,
        color: cTheme.primary,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

void report() {
  void request() async {
    Get.closeBottomSheet();
    SmartDialog.showLoading();
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.dismiss();
    SmartDialog.showNotify(
      msg: LocaleKeys.reportReceived.tr,
      notifyType: NotifyType.success,
    );
  }

  Map<String, Function> actions = {
    LocaleKeys.unwantedMsg.tr: request,
    LocaleKeys.violence.tr: request,
    LocaleKeys.child.tr: request,
    LocaleKeys.copyright.tr: request,
    LocaleKeys.personalInfo.tr: request,
    LocaleKeys.illegalDrugs.tr: request,
  };
  // sheetActions(actsion);
  final choose = ''.obs;
  showTheme1Sheet(
    showCancel: false,
    confirmText: LocaleKeys.confirmSel.tr,
    onConfirm: () async {
      request();
    },
    child: Obx(() {
      choose.value;
      return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: actions.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 8.w,
          mainAxisExtent: 42.h,
        ),
        itemBuilder: (context, index) {
          final key = actions.keys.elementAt(index);
          return InkWell(
            onTap: () {
              choose.value = key;
            },
            child: Container(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Color(0xffF4F4F6),
                borderRadius: BorderRadius.circular(21.w),
                border: Border.all(
                  color: choose.value == key
                      ? Color(0xffE2266C)
                      : Colors.transparent,
                  width: 1.w,
                ),
              ),
              child: Text(
                key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: choose.value == key
                      ? Color(0xffE2266C)
                      : Color(0xff434343),
                ),
              ),
            ),
          );
        },
      );
    }),
  );
}
