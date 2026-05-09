import 'dart:async';
import 'dart:io';

import 'package:novatalk/app/pages/call/phone_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/app_theme.dart';
import '../../configs/constans.dart';
import '../../utils/common_utils.dart';
import '../../utils/log/log_event.dart';

class PhoneGuidePage extends StatefulWidget {
  const PhoneGuidePage({super.key});

  @override
  State<PhoneGuidePage> createState() => _PhoneGuidePageState();
}

class _PhoneGuidePageState extends State<PhoneGuidePage>
    with RouteAware, WidgetsBindingObserver {
  late RoleRecords role;

  late VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isPlayed = false;
  StreamSubscription? _phoneStateSub;

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    role = args['role'];

    WidgetsBinding.instance.addObserver(this);

    _initVideoPlay();
  }

  void _initVideoPlay() async {
    final guide = role.characterVideoChat?.firstWhereOrNull(
      (e) => e.tag == 'guide',
    );
    var url = guide?.url;

    _controller = VideoPlayerController.networkUrl(Uri.parse(url ?? ''));

    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      _controller?.addListener(_videoListener);
      handlePhoneCall();

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _controller?.play();
          setState(() {});
        }
      });
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //  路由订阅
    // NavObs.instance.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    /// 取消路由订阅
    // NavObs.instance.routeObserver.unsubscribe(this);

    WidgetsBinding.instance.removeObserver(this);

    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _phoneStateSub?.cancel();
    _phoneStateSub = null;
    super.dispose();
  }

  @override
  void didPushNext() {
    // 页面被其他页面覆盖时调用
    _controller?.pause();
  }

  @override
  void didPopNext() {
    // 页面从其他页面回到前台时调用
    _controller?.play();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller?.pause();
      setState(() {});
    }
    if (state == AppLifecycleState.resumed) {
      _controller?.play();
      setState(() {});
    }
  }

  void _videoListener() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      setState(() {});
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final timeRemaining = duration - position;

    if (timeRemaining <= const Duration(milliseconds: 500)) {
      _isPlayed = true;
      _controller?.pause();
      setState(() {});
    }
  }

  //监听权限
  Future<bool?> requestPermission() async {
    var status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return true;
    }
  }

  //处理来电话播放器停止播放的操作
  void handlePhoneCall() async {
    if (_phoneStateSub != null) {
      return;
    }
    if (Platform.isAndroid) {
      await requestPermission();
    }
    // if (havePermission) {
    //   _phoneStateSub = PhoneState.stream.listen((event) {
    //     _controller?.pause();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Positioned.fill(child: role.avatar.iv(fit: BoxFit.cover)),
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller?.value.size.width,
                        height: _controller?.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(color: cTheme.primary),
                  );
                }
              },
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.25)),
              ),
            ),
            Obx(() {
              final vip = AppUser.inst.isVip.value;
              if (_isPlayed) {
                if (vip) {
                  return _buildButtons();
                }
                return _buildVipVideoView();
              }
              return _buildWaitingView();
            }),
            Positioned(
              left: 16.w,
              right: 16.w,
              top: MediaQuery.paddingOf(context).top + 5.h,
              child: _buildTopBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 64.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GuideCallButton(
            color: const Color(0xFFFF4747),
            icon: Assets.imagesIcCallHangup.iv(
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            onTap: () => Get.back(),
          ),
          91.horizontalSpace,
          _GuideCallButton(
            color: answerColor,
            icon: Assets.imagesIcCallAnswer.iv(
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            onTap: () {
              if (AppUser.inst.balance.value < ConsumeFrom.call.gems) {
                pushGem(ConsumeFrom.call);
                return;
              }
              offPhone(role: role, showVideo: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVipVideoView() {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 42.h,
          child: SizedBox(
            height: 311.h,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 231.h,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            Assets.imagesBgPhoneGuideVipCard,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          left: 28.w,
                          right: 28.w,
                          top: 60.h,
                          child: Text(
                            LocaleKeys.claim.tr.replaceAll('\n', ' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 28.w,
                          right: 28.w,
                          top: 107.h,
                          child: Text(
                            LocaleKeys.interactiveAI.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 46.5.w,
                          right: 46.5.w,
                          bottom: 31.h,
                          child: TapBox(
                            onTap: () {
                              pushVip(VipFrom.call);
                              logEvent('c_unlock_videocall');
                            },
                            child: Container(
                              height: 44.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFDFFD),
                                    Color(0xFFFF96F7),
                                  ],
                                ),
                              ),
                              child: LocaleKeys.proceed.tr.tv(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 9.w,
                  top: 1.h,
                  child: Image.asset(
                    Assets.imagesPhPhoneGuideVipDiamond,
                    width: 145.w,
                    height: 145.w,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: 131.w,
                  top: 68.h,
                  child: Transform.rotate(
                    angle: 0.2773,
                    child: Image.asset(
                      Assets.imagesPhPhoneGuideVipStar,
                      width: 55.w,
                      height: 57.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      width: Get.width - 32.w,
      height: 36.h,
      child: Row(
        children: [
          _GuideRolePill(role: role),
          const Spacer(),
          TapBox(
            onTap: () => Get.back(),
            child: buildCloseIcon(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingView() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 64.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 219.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF262626).withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              LocaleKeys.wantsYouVde.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          40.verticalSpace,
          _GuideCallButton(
            color: const Color(0xFFFF4747),
            icon: Assets.imagesIcCallHangup.iv(
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}

class _GuideRolePill extends StatelessWidget {
  const _GuideRolePill({required this.role});

  final RoleRecords role;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: role.avatar.iv(width: 36.w, height: 36.w, fit: BoxFit.cover),
          ),
          8.horizontalSpace,
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 104.w),
            child: Text(
              role.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (role.age != null) ...[
            4.horizontalSpace,
            _CallAgeBadge(age: role.age!),
          ],
        ],
      ),
    );
  }
}

class _CallAgeBadge extends StatelessWidget {
  const _CallAgeBadge({required this.age});

  final int age;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFDFFD), Color(0xFFFF96F7)],
        ),
      ),
      child: '$age'.tv(
        style: TextStyle(
          color: Colors.black,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _GuideCallButton extends StatelessWidget {
  const _GuideCallButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapBox(
      onTap: onTap,
      child: Container(
        width: 64.w,
        height: 64.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: icon,
      ),
    );
  }
}
