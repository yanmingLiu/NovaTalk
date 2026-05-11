import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/pages/chat/chat_controller.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/pages/home/home_controller.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/locales.g.dart';

import '../../../../generated/assets.dart';
import '../../../configs/constans.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/storage_util.dart';

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

  final ctr = Get.find<ChatRoomController>();
  List<RoleRecordsImages> images = <RoleRecordsImages>[];
  _ProfileTabType _selectedTab = _ProfileTabType.info;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null && arguments is RoleRecords) {
      role = arguments;
    }
    images = ctr.role.images ?? [];
    if (isCloB) {
      _selectedTab = _initialTab;
    }

    ever(ctr.roleImagesChanged, (_) {
      images = ctr.role.images ?? [];
      _ensureSelectedTabVisible();
      setState(() {});
    });
  }

  @override
  void dispose() {
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

  bool get _hasInfo => (role.aboutMe ?? '').trim().isNotEmpty;

  bool get _hasTags => isCloB && (role.tags?.isNotEmpty ?? false);

  bool get _hasPhotos => isCloB && images.isNotEmpty;

  List<_ProfileTabType> get _visibleTabs {
    return [
      if (_hasInfo) _ProfileTabType.info,
      if (_hasTags) _ProfileTabType.tags,
      if (_hasPhotos) _ProfileTabType.photos,
    ];
  }

  _ProfileTabType get _initialTab {
    final tabs = _visibleTabs;
    if (isCloB && tabs.contains(_ProfileTabType.tags)) {
      return _ProfileTabType.tags;
    }
    return tabs.firstOrNull ?? _ProfileTabType.info;
  }

  void _ensureSelectedTabVisible() {
    final tabs = _visibleTabs;
    if (tabs.isEmpty || !tabs.contains(_selectedTab)) {
      _selectedTab = tabs.firstOrNull ?? _ProfileTabType.info;
    }
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
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHero(),
                    16.verticalSpace,
                    _buildNameLine(),
                    22.verticalSpace,
                    _buildStatsCard(),
                    20.verticalSpace,
                    _buildActions(),
                    20.verticalSpace,
                    _buildProfileTabs(),
                    12.verticalSpace,
                    _buildTabContent(),
                  ],
                ),
              ),
            ),
            _buildTopControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 246.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipPath(
              clipper: _RoleProfileHeroClipper(),
              child: SizedBox(
                height: 200.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCoverImage(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.48),
                            Colors.black.withValues(alpha: 0.48),
                            Colors.black.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.63, 0.72],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 154.h,
            child: Container(
              width: 92.w,
              height: 92.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: role.avatar.iv(fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final cover = role.media?.characterImages?.firstOrNull ?? role.avatar;
    if (cover.isVoid) {
      return const ColoredBox(color: Colors.black);
    }
    return cover.iv(width: double.infinity, height: 200.h, fit: BoxFit.cover);
  }

  Widget _buildTopControls() {
    return Positioned(
      left: 16.w,
      right: 16.w,
      top: 55.h,
      child: Row(
        children: [
          TapBox(
            onTap: Get.back,
            child: buildBackIcon(color: Colors.white),
          ),
          const Spacer(),
          _buildMoreMenu(),
        ],
      ),
    );
  }

  Widget _buildMoreMenu() {
    void tapMenu(Function? onTap) {
      Navigator.of(Get.context!).pop();
      onTap?.call();
    }

    Widget buildItem({
      required String icon,
      required String text,
      required VoidCallback onTap,
      Color? color,
    }) {
      return TapBox(
        onTap: onTap,

        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon.iv(width: 24, color: color ?? Colors.white),
              4.horizontalSpace,
              text.tv(
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomPopup(
      showArrow: false,
      rootNavigator: true,
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 176.w,
        margin: EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildItem(
              icon: Assets.imagesIcClose,
              text: LocaleKeys.cleHistory,
              onTap: () => tapMenu(_clearHistory),
            ),
            Divider(
              height: 1.h,
              thickness: 0.5.h,
              color: Colors.white.withValues(alpha: 0.1),
              indent: 16.w,
              endIndent: 16.w,
            ),
            buildItem(
              icon: Assets.imagesIcReport,
              text: LocaleKeys.report,
              onTap: () => tapMenu(report),
            ),
            Divider(
              height: 1.h,
              thickness: 0.5.h,
              color: Colors.white.withValues(alpha: 0.1),
              indent: 16.w,
              endIndent: 16.w,
            ),
            buildItem(
              icon: Assets.imagesIcDelete,
              text: LocaleKeys.remChat,
              onTap: () => tapMenu(_deleteChat),
              color: const Color(0xFFFF4747),
            ),
          ],
        ),
      ),
      child: Assets.imagesIcMore.iv(width: 24.w, height: 24.w),
    );
  }

  Widget _buildNameLine() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              role.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                height: 1.2,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          8.horizontalSpace,
          if (role.age != null) _AgeBadge(text: '${role.age}'),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      height: 58.h,
      margin: EdgeInsets.symmetric(horizontal: 36.w),
      padding: EdgeInsets.symmetric(horizontal: 52.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(value: role.sessionCount ?? '0', label: 'Dialogue'),
          Container(
            width: 1.w,
            height: 32.h,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _StatItem(value: role.likes ?? '0', label: LocaleKeys.favorite.tr),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final liked = role.collect == true;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapBox(
          onTap: () async {
            await _follow();
          },
          child: _PillButton(
            text: liked ? LocaleKeys.liked.tr : LocaleKeys.like.tr,
            selected: true,
            filledSelected: !liked,
            loading: isLoading,
          ),
        ),
        21.horizontalSpace,
        TapBox(
          onTap: () {
            Get.popTo(Routes.CHAT_ROOM);
          },
          child: _PillButton(text: LocaleKeys.chat.tr),
        ),
      ],
    );
  }

  Widget _buildProfileTabs() {
    final tabs = _visibleTabs;
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              TapBox(
                onTap: () {
                  setState(() {
                    _selectedTab = tabs[i];
                  });
                },
                child: _ProfileTabLabel(
                  text: tabs[i].title,
                  selected: _selectedTab == tabs[i],
                ),
              ),
              if (i < tabs.length - 1) 40.horizontalSpace,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    _ensureSelectedTabVisible();
    switch (_selectedTab) {
      case _ProfileTabType.info:
        return buildInfoWidget();
      case _ProfileTabType.tags:
        return _buildTags();
      case _ProfileTabType.photos:
        return _buildImages();
    }
  }

  Widget buildTabBar() {
    return _buildProfileTabs();
  }

  Widget _buildTags() {
    if (!isCloB || role.tags == null || role.tags?.isEmpty == true) {
      return const SizedBox();
    }
    final tags = role.tags!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: tags.map(_buildTagChip).toList(),
      ),
    );
  }

  Widget _buildImages() {
    if (!isCloB || images.isEmpty) {
      return const SizedBox();
    }
    return Obx(() {
      ctr.roleImagesChanged.value;
      final imageCount = images.length;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 168 / 224,
            crossAxisSpacing: 7.w,
            mainAxisSpacing: 7.h,
          ),
          itemCount: imageCount,
          itemBuilder: (_, idx) {
            final image = images[idx];
            final unlocked = image.unlocked ?? false;
            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        ctr.onTapImage(image);
                      },
                      child: image.imageUrl.iv(fit: BoxFit.cover),
                    ),
                  ),
                  if (!unlocked)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () async {
                          ctr.onTapUnlockImage(image);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Assets.imagesIcGem.iv(
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                  2.horizontalSpace,
                                  Text(
                                    '${image.gems ?? 0}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w700,
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
            );
          },
        ),
      );
    });
  }

  Widget buildInfoWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.aboutMe ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return const SizedBox.shrink();
  }
}

class _RoleProfileHeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = 58 * size.width / 375;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

enum _ProfileTabType {
  info,
  tags,
  photos;

  String get title {
    switch (this) {
      case _ProfileTabType.info:
        return LocaleKeys.info.tr;
      case _ProfileTabType.tags:
        return LocaleKeys.tags.tr;
      case _ProfileTabType.photos:
        return LocaleKeys.photos.tr;
    }
  }
}

class _AgeBadge extends StatelessWidget {
  const _AgeBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 33.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
          stops: [0.058, 0.922],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.sp,
          height: 1.15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.2,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        2.verticalSpace,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14.sp,
            height: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    this.selected = false,
    this.filledSelected = true,
    this.loading = false,
  });

  final String text;
  final bool selected;
  final bool filledSelected;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24.r);
    final isFilled = selected && filledSelected;
    final isOutlined = selected && !filledSelected;
    final mainPinkColor = const Color(0xFFFF96F7);

    return Container(
      width: 92.w,
      height: 32.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled
            ? null
            : (selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15)),
        gradient: isFilled
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
                stops: [0.058, 0.922],
              )
            : null,
        borderRadius: borderRadius,
        border: Border.all(
          color: isFilled || isOutlined || (selected && loading)
              ? mainPinkColor
              : Colors.transparent,
          width: 1.w,
        ),
      ),
      child: loading
          ? SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 1.5.w,
                color: isFilled ? Colors.black : mainPinkColor,
              ),
            )
          : Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isFilled
                    ? Colors.black
                    : isOutlined
                    ? mainPinkColor
                    : Colors.white,
                fontSize: 14.sp,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

class _ProfileTabLabel extends StatelessWidget {
  const _ProfileTabLabel({required this.text, required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14.sp,
          height: 1.2,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFFF96F7),
                  const Color(0xFFFF96F7).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Widget _buildTagChip(String text) {
  return Container(
    width: 109.w,
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFFF96F7).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFFFF96F7),
        fontSize: 14.sp,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
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
      return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: actions.length,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => 8.verticalSpace,
        itemBuilder: (context, index) {
          final key = actions.keys.elementAt(index);
          return InkWell(
            onTap: () {
              choose.value = key;
            },
            child: Container(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Text(
                key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: choose.value == key
                      ? Color(0xFFFF96F7)
                      : Color(0xFF000000),
                ),
              ),
            ),
          );
        },
      );
    }),
  );
}
