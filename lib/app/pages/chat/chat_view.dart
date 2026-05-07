import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/conversation_entity.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/home_top_entries.dart';
import 'package:novatalk/app/widgets/keep_alive_wrapper.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';
import '../../utils/common_utils.dart';
import '../../utils/time_util.dart';
import '../../widgets/common_widget.dart';
import 'chat_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';

class ChatView extends GetBuildView<ChatController> {
  const ChatView({super.key});

  @override
  Widget builder(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            buildDefaultBg(),
            SafeArea(
              bottom: false,
              child: DefaultTabController(
                length: 2,
                animationDuration: const Duration(milliseconds: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ChatHeader(),
                    20.verticalSpace,
                    _ChatTabs(
                      onTap: (index) {
                        controller.setTabIndex(index);
                      },
                    ),
                    16.verticalSpace,
                    Expanded(
                      child: TabBarView(
                        children: [
                          KeepAliveWrapper(
                            child: SessionListView(
                              controller: controller.sessionListController,
                            ),
                          ),
                          KeepAliveWrapper(
                            child: SessionListView(
                              controller: controller.likedSessionListController,
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
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 7.h),
      child: Row(
        children: [
          const HomeGemPill(),
          20.horizontalSpace,
          Obx(
            () => AppUser.inst.isVip.value
                ? sh
                : TapBox(
                    onTap: () {
                      pushVip(VipFrom.homevip);
                    },
                    child: const HomeVipEntry(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatTabs extends StatefulWidget {
  const _ChatTabs({required this.onTap});

  final ValueChanged<int> onTap;

  @override
  State<_ChatTabs> createState() => _ChatTabsState();
}

class _ChatTabsState extends State<_ChatTabs> {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabController = DefaultTabController.maybeOf(context);
    if (_tabController == tabController) {
      return;
    }
    _tabController?.removeListener(_handleTabChanged);
    _tabController = tabController;
    _tabController?.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChanged);
    super.dispose();
  }

  void _handleTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _tabController?.index ?? 0;

    return SizedBox(
      height: 22.h,
      child: TabBar(
        onTap: widget.onTap,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicator: const BoxDecoration(),
        labelPadding: EdgeInsets.only(left: 16.w, right: 35.w),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: [
          _ChatTab(
            text: LocaleKeys.contactedBefore.tr,
            selected: selectedIndex == 0,
          ),
          _ChatTab(text: LocaleKeys.favorites.tr, selected: selectedIndex == 1),
        ],
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.text, required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 22.h,
      child: SizedBox(
        height: 22.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            if (selected)
              Positioned(
                left: 0,
                bottom: -1.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF96F7),
                        const Color(0xFFFF96F7).withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: SizedBox(width: 12.w, height: 12.w),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.70),
                fontSize: selected ? 16.sp : 14.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionListView extends StatefulWidget {
  final SessionListController controller;

  const SessionListView({super.key, required this.controller});

  @override
  State<SessionListView> createState() => _SessionListViewState();
}

class _SessionListViewState extends State<SessionListView> {
  late final ctr = widget.controller;

  @override
  void initState() {
    super.initState();
    ctr.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      onRefresh: ctr.onRefresh,
      childBuilder: (context, physics) {
        return Obx(() {
          if (ctr.pageData.isEmpty) {
            return Center(child: _buildChatEmpty());
          }
          return ListView.separated(
            physics: physics,
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 108.h),
            separatorBuilder: (_, index) {
              return 12.verticalSpace;
            },
            itemBuilder: (_, index) {
              final item = ctr.pageData[index];
              return InkWell(
                onTap: () => ctr.onItemTap(item),
                borderRadius: BorderRadius.circular(20.r),
                child: _SessionCard(item: item, showLike: ctr.isLiked),
              );
            },
            itemCount: ctr.pageData.length,
          );
        });
      },
    );
  }
}

Widget _buildChatEmpty() {
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.item, required this.showLike});

  final ConversationRecords item;
  final bool showLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black, width: 1.w),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF21001E)],
          stops: [0, 0.952],
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: item.avatar.iv(width: 72.w, height: 72.w, fit: BoxFit.cover),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (item.title ?? '').toString().tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                3.verticalSpace,
                (item.lastMessage ?? '').toString().tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          12.horizontalSpace,
          _SessionTrailing(item: item, showLike: showLike),
        ],
      ),
    );
  }
}

class _SessionTrailing extends StatelessWidget {
  const _SessionTrailing({required this.item, required this.showLike});

  final ConversationRecords item;
  final bool showLike;

  @override
  Widget build(BuildContext context) {
    final time = item.updateTime == null
        ? ''
        : TimeUtil.formatToday(item.updateTime!);
    return SizedBox(
      width: 34.w,
      height: 60.h,
      child: Column(
        mainAxisAlignment: showLike
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          time.tv(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF797C7B),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (showLike) Assets.imagesIcLike.iv(width: 20.w, height: 20.w),
        ],
      ),
    );
  }
}

Widget buildLikeThemeBtn({
  EdgeInsetsGeometry? padding,
  double? radius,
  Widget? contentWidget,
  BoxShape shape = BoxShape.rectangle,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius ?? 12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.w,
          ),
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: contentWidget ?? Assets.imagesIcLike.iv(width: 12.w),
      ),
    ),
  );
}
