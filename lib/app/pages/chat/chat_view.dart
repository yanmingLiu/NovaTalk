import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/conversation_entity.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/keep_alive_wrapper.dart';
import 'package:novatalk/app/widgets/overall_build_widget.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';
import '../../utils/common_utils.dart';
import '../../utils/time_util.dart';
import '../../widgets/common_widget.dart';
import '../home/home_view.dart';
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

class _ChatTabs extends StatelessWidget {
  const _ChatTabs({required this.onTap});

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22.h,
      child: TabBar(
        onTap: onTap,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicator: _ChatTabIndicator(),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.70),
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        labelPadding: EdgeInsets.only(left: 16.w, right: 35.w),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(height: 22.h, text: LocaleKeys.contactedBefore.tr),
          Tab(height: 22.h, text: LocaleKeys.favorites.tr),
        ],
      ),
    );
  }
}

class _ChatTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ChatTabIndicatorPainter();
  }
}

class _ChatTabIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = Size(12.w, 12.w);
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy + (configuration.size?.height ?? 22.h) - size.height - 1.h,
      size.width,
      size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4.r));
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF96F7),
          const Color(0xFFFF96F7).withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
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
            return Center(child: buildEmpty());
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
