part of 'home_view.dart';

const _homeAccent = Color(0xFFFF96F7);
const _homePurple = Color(0xFFC7ABFF);
const _homeCardBg = Color(0xFF40263E);
final _horizontalLoadMoreAt = Expando<int>();

class HomeDiscoverView extends StatefulWidget {
  const HomeDiscoverView({super.key});

  @override
  State<HomeDiscoverView> createState() => _HomeDiscoverViewState();
}

class _HomeDiscoverViewState extends State<HomeDiscoverView> {
  final _refreshController = EasyRefreshController();
  final _bannerPageController = PageController(viewportFraction: 360 / 375);

  late final PageLoadRoleController _forYouController = _createController(
    DiscoverListType.all,
    pageSize: 5,
    forYou: true,
  );

  late final List<_HomeRoleSection> _sections = [
    _HomeRoleSection(
      title: LocaleKeys.allItems,
      type: DiscoverListType.all,
      controller: _createController(DiscoverListType.all, pageSize: 10),
    ),
    _HomeRoleSection(
      title: LocaleKeys.cufits,
      type: DiscoverListType.outfits,
      controller: _createController(DiscoverListType.outfits, pageSize: 10),
    ),
    _HomeRoleSection(
      title: LocaleKeys.videoChat,
      type: DiscoverListType.video,
      controller: _createController(DiscoverListType.video, pageSize: 10),
    ),
    _HomeRoleSection(
      title: LocaleKeys.lifelike,
      type: DiscoverListType.realistic,
      controller: _createController(DiscoverListType.realistic, pageSize: 10),
    ),
    _HomeRoleSection(
      title: LocaleKeys.animeMode,
      type: DiscoverListType.anime,
      controller: _createController(DiscoverListType.anime, pageSize: 10),
    ),
  ];

  int _bannerIndex = 0;

  RolesController get logic => Get.find<RolesController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial(showLoading: true);
    });
  }

  PageLoadRoleController _createController(
    DiscoverListType type, {
    required int pageSize,
    bool? forYou,
  }) {
    final controller = PageLoadRoleController(forYou: forYou)
      ..pageSize = pageSize;
    controller.enableHomeCall = type == DiscoverListType.all && forYou != true;
    controller.onInit(type);
    return controller;
  }

  Future<void> _loadInitial({bool showLoading = false}) async {
    if (showLoading) {
      SmartDialog.showLoading();
    }
    try {
      await Future.wait([
        _forYouController.onRefresh(),
        ..._sections.map((section) => section.controller.onRefresh()),
      ]);
    } finally {
      if (showLoading) {
        SmartDialog.dismiss();
      }
    }
  }

  Future<void> _refreshSections() async {
    await Future.wait(
      _sections.map((section) => section.controller.onRefresh()),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _bannerPageController.dispose();
    _forYouController.onClose();
    for (final section in _sections) {
      section.controller.onClose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            buildDefaultBg(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: EasyRefresh(
                      controller: _refreshController,
                      header: const ClassicHeader(),
                      triggerAxis: Axis.vertical,
                      onRefresh: _refreshSections,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            20.verticalSpace,
                            const _HomeSectionHeader(
                              title: "Editor's Picks",
                              showViewAll: false,
                            ),
                            14.verticalSpace,
                            _buildFeaturedBanner(),
                            22.verticalSpace,
                            ..._sections.map((section) {
                              return _HomeCategorySection(
                                section: section,
                                onViewAll: () => _openSection(section),
                                onItemTap: (role) {
                                  logic.onItemTap(role, section.type);
                                },
                              );
                            }),
                            24.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                  60.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 7.h),
      child: Row(
        children: [
          HomeGemPill(),
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
          const Spacer(),
          _HomeIconButton(
            icon: Assets.imagesIcSearch,
            onTap: () {
              Get.toNamed(Routes.SEARCH);
            },
          ),
          16.horizontalSpace,
          if (CloUtil.isCloB)
            _HomeIconButton(
              icon: Assets.imagesIcFilter,
              onTap: logic.showFilter,
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Obx(() {
      final roles = _forYouController.pageData;
      if (roles.isEmpty) {
        return SizedBox(
          height: 275.h,
          child: Center(
            child: _forYouController.isLoading.value
                ? const SLoading()
                : const _HomeEmptyText(),
          ),
        );
      }

      final visibleDotCount = min(roles.length, 5);
      final activeDot = _bannerIndex.clamp(0, visibleDotCount - 1);
      return Column(
        children: [
          SizedBox(
            height: 257.h,
            child: PageView.builder(
              controller: _bannerPageController,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              padEnds: false,
              itemCount: roles.length,
              onPageChanged: (index) {
                setState(() {
                  _bannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final role = roles[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16.w : 3.5.w,
                    right: 3.5.w,
                  ),
                  child: _FeaturedRoleCard(
                    role: role,
                    onTap: () {
                      logic.onItemTap(role, DiscoverListType.all);
                    },
                  ),
                );
              },
            ),
          ),
          12.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(visibleDotCount, (index) {
              final active = index == activeDot;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 6.w : 5.w,
                height: active ? 6.w : 5.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: active
                      ? _homeAccent
                      : Colors.white.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  void _openSection(_HomeRoleSection section) {
    if (section.type == DiscoverListType.video) {
      logEvent("c_videochat");
    }
    Get.to(
      () => HomeDiscoverCategoryPage(title: section.title, type: section.type),
    );
  }
}

class _HomeRoleSection {
  const _HomeRoleSection({
    required this.title,
    required this.type,
    required this.controller,
  });

  final String title;
  final DiscoverListType type;
  final PageLoadRoleController controller;
}

class HomeGemPill extends StatelessWidget {
  const HomeGemPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TapBox(
        onTap: () {
          pushGem(ConsumeFrom.home);
        },
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.imagesIcGem.iv(width: 20.w, height: 20.w),
              4.horizontalSpace,
              AppUser.inst.balance.value.tv(
                style: TextStyle(
                  color: _homePurple,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeVipEntry extends StatelessWidget {
  const HomeVipEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      child: Assets.imagesIcVip.iv(width: 24.w),
    );
  }
}

class _HomeIconButton extends StatelessWidget {
  const _HomeIconButton({required this.icon, required this.onTap});

  final String icon;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: icon.iv(width: 24.w, height: 24.w, fit: BoxFit.contain),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    this.showViewAll = true,
    this.onViewAll,
  });

  final String title;
  final bool showViewAll;
  final Function? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -4.w,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    gradient: LinearGradient(
                      colors: [_homeAccent, _homeAccent.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              title.tr.tv(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (showViewAll)
            TapBox(
              onTap: onViewAll,
              child: Row(
                children: [
                  LocaleKeys.viewAll.tv(
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  4.horizontalSpace,
                  Assets.imagesIcNext.iv(width: 16.w, height: 16.w),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection({
    required this.section,
    required this.onViewAll,
    required this.onItemTap,
  });

  final _HomeRoleSection section;
  final Function onViewAll;
  final void Function(RoleRecords role) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeSectionHeader(title: section.title, onViewAll: onViewAll),
          8.verticalSpace,
          Obx(() {
            final roles = section.controller.pageData;
            if (roles.isEmpty) {
              return SizedBox(
                height: 168.h,
                child: Center(
                  child: section.controller.isLoading.value
                      ? const SLoading()
                      : const _HomeEmptyText(),
                ),
              );
            }
            return SizedBox(
              height: 168.h,
              child: _HorizontalLoadMoreListener(
                controller: section.controller,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return _CompactRoleCard(
                      role: role,
                      onTap: () => onItemTap(role),
                    );
                  },
                  separatorBuilder: (context, index) => 7.horizontalSpace,
                  itemCount: roles.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeaturedRoleCard extends StatelessWidget {
  const _FeaturedRoleCard({required this.role, required this.onTap});

  final RoleRecords role;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final isCollect = role.collect ?? false;
    return TapBox(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCollect ? 1.w : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCollect ? _homeAccent : Colors.transparent,
            width: isCollect ? 1.w : 0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            color: _homeCardBg,
            child: Stack(
              children: [
                Positioned.fill(child: role.avatar.iv(fit: BoxFit.cover)),
                Positioned.fill(child: _RoleImageShade(radius: 16.r)),
                if (isCollect)
                  Positioned.fill(child: _RoleCollectOverlay(radius: 16.r)),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: _LikePill(role: role),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 98.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        color: Colors.black.withValues(alpha: 0.40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipOval(
                                  child: role.avatar.iv(
                                    width: 36.w,
                                    height: 36.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                6.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _RoleNameAge(role: role),
                                      5.verticalSpace,
                                      _RoleTags(role: role, maxCount: 2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            8.verticalSpace,
                            (role.intro ?? role.aboutMe).tv(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _CompactRoleCard extends StatelessWidget {
  const _CompactRoleCard({required this.role, required this.onTap});

  final RoleRecords role;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    final isCollect = role.collect ?? false;
    final showBorder = isCollect || role.vip == true;
    return TapBox(
      onTap: onTap,
      child: Container(
        width: 126.w,
        decoration: BoxDecoration(
          color: _homeCardBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: showBorder ? _homeAccent : Colors.transparent,
            width: 1.w,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              Positioned.fill(child: role.avatar.iv(fit: BoxFit.cover)),
              Positioned.fill(child: _RoleImageShade(radius: 8.r)),
              if (isCollect)
                Positioned.fill(child: _RoleCollectOverlay(radius: 8.r)),
              Positioned(
                top: 6.h,
                right: 5.w,
                child: _LikePill(role: role),
              ),
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoleNameAge(role: role),
                    4.verticalSpace,
                    _RoleTags(role: role, maxCount: 2),
                    4.verticalSpace,
                    (role.intro ?? role.aboutMe).tv(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.12,
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

class _HorizontalLoadMoreListener extends StatelessWidget {
  const _HorizontalLoadMoreListener({
    required this.controller,
    required this.child,
  });

  final PageLoadRoleController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis != Axis.horizontal) {
          return false;
        }

        final pixels = notification.metrics.pixels;
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        if (maxScrollExtent > 0 && maxScrollExtent - pixels <= 24.w) {
          _loadMore();
        }

        return true;
      },
      child: child,
    );
  }

  void _loadMore() {
    if (controller.isLoading.value) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastAt = _horizontalLoadMoreAt[controller] ?? 0;
    if (now - lastAt < 900) {
      return;
    }

    _horizontalLoadMoreAt[controller] = now;
    controller.onLoadMore();
  }
}

class _RoleImageShade extends StatelessWidget {
  const _RoleImageShade({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.46, 1],
          colors: [
            Colors.black.withValues(alpha: 0.02),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
      ),
    );
  }
}

class _RoleCollectOverlay extends StatelessWidget {
  const _RoleCollectOverlay({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: _homeAccent.withValues(alpha: 0.12),
      ),
    );
  }
}

class _LikePill extends StatelessWidget {
  const _LikePill({required this.role});

  final RoleRecords role;

  @override
  Widget build(BuildContext context) {
    final isCollect = role.collect ?? false;
    final textColor = isCollect ? _homeAccent : Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCollect ? Icons.favorite : Icons.favorite_border,
                color: textColor,
                size: 12.w,
              ),
              (role.likes ?? "0").tv(
                style: TextStyle(
                  color: textColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleNameAge extends StatelessWidget {
  const _RoleNameAge({required this.role});

  final RoleRecords role;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: role.name.tv(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!role.age.isVoid)
          Container(
            margin: EdgeInsets.only(left: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFDFFD), _homeAccent],
              ),
            ),
            child: role.age.tv(
              style: TextStyle(
                color: Colors.black,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _RoleTags extends StatelessWidget {
  const _RoleTags({required this.role, this.maxCount = 2});

  final RoleRecords role;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final tags = _displayTags(role).take(maxCount).toList();
    if (tags.isEmpty) {
      return sh;
    }

    return Wrap(
      spacing: 4.w,
      runSpacing: 3.h,
      children: tags.map((tag) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: tag.tv(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _displayTags(RoleRecords role) {
    final tags = role.tags;
    final result = tags != null && tags.length > 3
        ? tags.take(3).toList()
        : [...?tags];
    return insertHotTag(role.tagType, result);
  }
}

class _HomeEmptyText extends StatelessWidget {
  const _HomeEmptyText();

  @override
  Widget build(BuildContext context) {
    return LocaleKeys.noData.tv(
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 13.sp,
      ),
    );
  }
}

class HomeDiscoverCategoryPage extends StatelessWidget {
  const HomeDiscoverCategoryPage({
    super.key,
    required this.title,
    required this.type,
  });

  final String title;
  final DiscoverListType type;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: TapBox(
            onTap: Get.back,
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 30.w,
            ),
          ),
          title: title.tv(
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: RoleContentWidget(type: type, byHome: true),
      ),
    );
  }
}
