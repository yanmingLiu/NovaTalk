import 'package:novatalk/app/configs/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/entities/role_tags_entity.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/utils/purchase_helper.dart';
import 'package:novatalk/app/utils/storage_util.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:novatalk/generated/locales.g.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../generated/assets.dart';
import '../../configs/constans.dart';
import '../../routes/app_pages.dart';
import '../../utils/facebook_util.dart';
import '../../utils/log/log_event.dart';
import '../chat/chat_room/chat_room_controller.dart';
import '../chat/role_profile/role_profile_view.dart';
import 'filtter_view.dart';

enum DiscoverListType {
  all,
  realistic,
  anime,
  outfits,
  video,
  createImage,
  createVideo,
}

class RolesController extends GetxController {
  final tabs = [
    (LocaleKeys.allItems, DiscoverListType.all),
    if (CloUtil.isCloB) (LocaleKeys.cufits, DiscoverListType.outfits),
    if (CloUtil.isCloB) (LocaleKeys.videoChat, DiscoverListType.video),
    (LocaleKeys.lifelike, DiscoverListType.realistic),
    (LocaleKeys.animeMode, DiscoverListType.anime),
  ];
  List<RoleTagsEntity> roleTags = [];
  var selectTags = <RoleTagsTagList>{}.obs;

  Rx<Set<RoleTagsTagList>> filterEvent = Rx<Set<RoleTagsTagList>>({});

  // 关注
  Rx<(FollowEvent, String)> followEvent = (FollowEvent.follow, '').obs;

  @override
  void onInit() {
    super.onInit();
    loadTags();
    recordInstallTime();
    if (CloUtil.isCloB) {
      launchJump();
    }
  }

  Future<RoleRecords?> getSplashRole() async {
    final role = await ApiSvc.splashRandomRole();
    return role;
  }

  void launchJump() async {
    await AppUser.inst.refreshUser();
    final isShowDailyReward = await shouldShowDailyReward();
    final isVip = AppUser.inst.isVip.value;
    final isFirstLaunch = StorageUtils.isRestartApp == false;
    if (isFirstLaunch) {
      // 记录安装时间
      recordInstallTime();
      // 记录为重启
      StorageUtils.isRestartApp = true;

      if (CloUtil.isCloB) {
        // 首次启动 获取指定人物聊天
        final startRole = await getSplashRole();
        if (startRole != null) {
          final roleId = startRole.id;
          pushChatRoom(roleId);
        } else {
          await PurchaseHelper.inst.getProducts();
          jumpVip(isFirstLaunch);
        }
      }
    } else {
      // 非首次启动 判断弹出奖励弹窗
      if (isShowDailyReward) {
        // 更新奖励时间戳
        StorageUtils.lastRewardDate = DateTime.now().millisecondsSinceEpoch;
        showLoginReward();
      } else {
        // 非vip用户 跳转订阅页
        if (!isVip && CloUtil.isCloB) {
          jumpVip(isFirstLaunch);
        }
      }
    }
  }

  Future<bool> shouldShowDailyReward() async {
    final installTimeMillis = StorageUtils.installTime;
    if (installTimeMillis <= 0) {
      return false; // 没有记录安装时间，不处理
    }

    final installTime = DateTime.fromMillisecondsSinceEpoch(installTimeMillis);
    final now = DateTime.now();

    // 安装后第一天不弹窗，只有从第二天开始才弹窗
    final isAfterSecondDay =
        now.year > installTime.year ||
        (now.year == installTime.year && now.month > installTime.month) ||
        (now.year == installTime.year &&
            now.month == installTime.month &&
            now.day > installTime.day);

    if (!isAfterSecondDay) {
      return false;
    }

    // 检查今天是否已经发过奖励（避免重复弹窗）
    final lastRewardDateMillis = StorageUtils.lastRewardDate;
    if (lastRewardDateMillis > 0) {
      final lastRewardDate = DateTime.fromMillisecondsSinceEpoch(
        lastRewardDateMillis,
      );

      // 如果今天已经发过奖励，则不弹窗
      if (now.year == lastRewardDate.year &&
          now.month == lastRewardDate.month &&
          now.day == lastRewardDate.day) {
        return false;
      }
    }

    return true; // 可以发奖励
  }

  @override
  void onReady() {
    super.onReady();
    listenerConnectivityChanged();
    Future.delayed(Duration(milliseconds: 200), () {
      AppUser.inst.refreshUser();
    });
  }

  Future loadTags() async {
    var data = await ApiSvc.getRoleTags();
    if (data != null) {
      roleTags.assignAll(data);
    }
  }

  Future<void> showFilter() async {
    if (roleTags.isEmpty) {
      await loadTags();
    }
    if (roleTags.isEmpty) {
      SmartDialog.showToast('tags unavailable');
      return;
    }
    Get.bottomSheet(
      buildTheme2SheetRootWidget(
        child: SizedBox(height: Get.height / 1.8, child: FilterView()),
      ),
      isScrollControlled: true,
    );
  }

  void onItemTap(RoleRecords role, DiscoverListType type) {
    // showLoginReward();
    // return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (role.id.val.isEmpty) {
      return;
    }
    if (type == DiscoverListType.video) {
      logEvent("c_videochat_char");
      Get.toNamed(Routes.PHONE_GUIDE, arguments: {'role': role});
      return;
    }
    pushChatRoom(role.id.val);
  }

  void recordInstallTime() {
    if (StorageUtils.installTime > 0) {
      return;
    }
    StorageUtils.installTime = DateTime.now().millisecondsSinceEpoch;
  }

  void jumpVip(bool isFirstLaunch) async {
    Get.toNamed(
      Routes.VIP,
      arguments: StorageUtils.isRestartApp ? VipFrom.relaunch : VipFrom.launch,
    );

    var event = CloUtil.isCloB ? 't_vipb' : 't_vipa';

    if (StorageUtils.isRestartApp) {
      event = '${event}_relaunch';
    } else {
      event = '${event}_launch';
      StorageUtils.isRestartApp = true;
    }
    logEvent(event);
  }

  void listenerConnectivityChanged() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status
          .where((element) => element != ConnectivityResult.none)
          .isNotEmpty) {
        FacebookSDKUtil.retryIfNeed();
        CloUtil.request();
        AppUser.inst.refreshUser();
      }
    });
  }

  void onTopCollect() async {
    logEvent("dailyreward_pop_collect_click");
    SmartDialog.showLoading();
    await ApiSvc.getDailyReward();
    SmartDialog.dismiss();
    AppUser.inst.refreshUser();
  }

  void showLoginReward() {
    bool isVip = AppUser.inst.isVip.value;
    final body = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Assets.imagesPhGem2.iv(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            70.verticalSpace,
            LocaleKeys.dailyBonus.tv(
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            10.horizontalSpace,
            (isVip ? "+50" : "+20").tv(
              style: TextStyle(
                fontSize: 24.sp,
                color: cTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              constraints: BoxConstraints(minHeight: 220.h),
              child: isVip
                  ? sh
                  : Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: buildTextSpans(
                          origin: LocaleKeys.pro50.tr,
                          targets: ["50", "@i"],
                          style: tTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                          buildTargetTextSpan:
                              (String target, TextStyle? style, int index) {
                                if (index == 0) {
                                  return TextSpan(
                                    text: "+$target",
                                    style: style?.copyWith(
                                      color: cTheme.scrim,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20.sp,
                                    ),
                                  );
                                }
                                return WidgetSpan(
                                  child: Assets.imagesIcGem
                                      .iv(height: 22.w)
                                      .marginOnly(bottom: 4.h),
                                  alignment: PlaceholderAlignment.middle,
                                );
                              },
                        ),
                      ),
                    ).marginOnly(bottom: 20.h),
            ),
            buildTheme3Btn(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 68.w),
              title: isVip ? LocaleKeys.claimNow.tr : LocaleKeys.goPro.tr,
              onTap: () {
                if (isVip) {
                  onTopCollect();
                  Get.closeDialog();
                } else {
                  logEvent("dailyreward_pop_pro_click");
                  pushVip(VipFrom.ldailyrd);
                }
              },
            ),
            if (!isVip)
              buildTheme3Btn(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 68.w, right: 68.w, top: 12.h),
                title: LocaleKeys.claimNow.tr,
                titleWidget: LocaleKeys.claimNow.tv(style: tTheme.titleMedium!),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(color: Colors.white, width: 1.w),
                ),
                onTap: () {
                  onTopCollect();
                  Get.closeDialog();
                },
              ),
          ],
        ),
      ],
    );
    Get.dialog(body.marginOnly(top: 100.h));
    // if (isVip) {
    //   Theme1Dialog.showBottomOnlyBtn(
    //     body,
    //     minHeight: 210.h,
    //     onTap: () {
    //       onTopCollect();
    //     },
    //   );
    // } else {
    //   Theme1Dialog.showBottomTwoBtn(
    //     titleWidget: sh,
    //     cancelText: LocaleKeys.claimNow,
    //     onCancel: () {
    //       onTopCollect();
    //     },
    //     confirmWidget: Stack(
    //       children: [
    //         buildTheme3Btn(
    //           alignment: Alignment.center,
    //           title: LocaleKeys.goPro.tr,
    //           onTap: () {
    //             logEvent("dailyreward_pop_pro_click");
    //             pushVip(VipFrom.ldailyrd);
    //           },
    //         ),
    //
    //       ],
    //     ),
    //     contentWidget: body,
    //   );
    // }
  }
}

class PageLoadRoleController with MxPageData<RoleRecords> {
  String? rendStyl;
  bool? videoChat;
  bool? genVideo;
  bool? genImg;
  bool? dress;
  bool? forYou;
  bool enableHomeCall = true;
  String? name;
  List<int> tagIds = [];

  var easyRefreshController = EasyRefreshController();

  Worker? filter;
  Worker? follow;

  PageLoadRoleController({
    this.rendStyl,
    this.videoChat,
    this.genVideo,
    this.genImg,
    this.dress,
    this.forYou,
    this.enableHomeCall = true,
    this.name,
    this.tagIds = const [],
  });

  @override
  onRefresh() async {
    await super.onRefresh();
    if (enableHomeCall) {
      Get.find<HomeController>().onCall(pageData);
    }
  }

  Future<void> onCollect(RoleRecords role) async {
    // showHelpUs();
    // return;

    final chatId = role.id;
    if (chatId == null) {
      return;
    }
    SmartDialog.showLoading();
    if (role.collect == true) {
      final res = await ApiSvc.cancelCollectRole(chatId);
      if (res) {
        role.collect = false;
        pageData.refresh();
        Get.find<RolesController>().followEvent.value = (
          FollowEvent.unfollow,
          chatId,
        );
      }
    } else {
      final res = await ApiSvc.collectRole(chatId);
      if (res) {
        role.collect = true;
        pageData.refresh();
        Get.find<RolesController>().followEvent.value = (
          FollowEvent.follow,
          chatId,
        );
        collectShowHelpUs(role.id!);
      }
    }
    SmartDialog.dismiss();
  }

  @override
  Future<List<RoleRecords>> loadData() async {
    var data = await ApiSvc.getRoleList(
      page: page,
      size: pageSize,
      rendStyl: rendStyl,
      videoChat: videoChat,
      genImg: genImg,
      genVideo: genVideo,
      tags: tagIds,
      dress: dress,
      forYou: forYou,
      name: name,
    );
    if (videoChat == true) {}
    return data?.records ?? [];
  }

  void onInit(DiscoverListType type) {
    switch (type) {
      case DiscoverListType.realistic:
        rendStyl = type.name;
        break;
      case DiscoverListType.anime:
        rendStyl = type.name;
        break;
      case DiscoverListType.outfits:
        dress = true;
        break;

      case DiscoverListType.video:
        videoChat = true;
        break;
      case DiscoverListType.createImage:
        genImg = true;
        break;
      case DiscoverListType.createVideo:
        genVideo = true;
        break;

      default:
    }
    var rolesController = $<RolesController>();
    if (rolesController?.selectTags.isNotEmpty == true) {
      final ids = rolesController!.selectTags.map((e) => e.id!).toList();
      tagIds = ids;
    }
    if (rolesController != null) {
      filter = ever(rolesController.filterEvent, (tags) async {
        final ids = tags.map((e) => e.id!).toList();
        tagIds = ids;
        SmartDialog.showLoading(displayTime: 10.minutes);
        await onRefresh();
        SmartDialog.dismiss();
      });
    }
    follow = ever(rolesController!.followEvent, (even) {
      try {
        final e = even.$1;
        final id = even.$2;

        final index = pageData.indexWhere((element) => element.id == id);
        if (index != -1) {
          pageData[index].collect = e == FollowEvent.follow;
        }
        rolesController.update();
      } catch (e) {
        goPrint(e.toString());
      }
    });
  }

  void onClose() {
    filter?.dispose();
    follow?.dispose();
  }

  @override
  void dispose() {
    onClose();
    super.dispose();
  }
}

class HomeController extends GetxController {
  // 主动来电
  final List<RoleRecords> _callList = [];
  RoleRecords? _callRole;
  int _callCount = 0;
  int _lastCallTime = 0;
  bool _calling = false;
  bool selectedDiscover = true;

  var currentTabIndex = 0;

  void setCurrentTabIndex(int index) {
    currentTabIndex = index;
    update();
  }

  void onCall(List<RoleRecords>? list) async {
    try {
      if (list == null || list.isEmpty) return;
      _callList.assignAll(list);
      final role = list
          .where(
            (element) =>
                element.gender == 1 && element.renderStyle == 'REALISTIC',
          )
          .toList()
          .randomOrNull;
      if (role == null) {
        return;
      }
      _callRole = role;
      callOut();
    } catch (e) {
      goPrint(e.toString());
    }
  }

  Future callOut() async {
    try {
      if (!canCall() || _calling) {
        return;
      }
      if (_callRole == null) {
        return;
      }

      String? url;
      if (_callRole!.videoChat == true) {
        logEvent('t_ai_videocall');
        final guide = _callRole?.characterVideoChat?.firstWhereOrNull(
          (e) => e.tag == 'guide',
        );
        url = guide?.gifUrl;
      } else {
        logEvent('t_ai_audiocall');
        url = _callRole?.avatar;
      }

      if (url == null || url.isEmpty) {
        return;
      }

      await Future.delayed(const Duration(seconds: 6));

      if (!canCall() || _calling) {
        return;
      }

      final roleId = _callRole?.id;
      if (roleId == null || roleId.isEmpty) {
        return;
      }

      _lastCallTime = DateTime.now().millisecondsSinceEpoch;
      _callCount++;

      const sessionId = 0;

      await pushPhone(
        sessionId: sessionId,
        role: _callRole!,
        showVideo: true,
        callState: CallState.incoming,
      );
      _calling = true;
      final role = _callList
          .where(
            (element) =>
                element.gender == 1 &&
                element.renderStyle == 'REALISTIC' &&
                element.id != _callRole?.id,
          )
          .toList()
          .randomOrNull;
      if (role == null) {
        return;
      }
      _callRole = role;
    } catch (e) {
      goPrint(e.toString());
    } finally {
      _calling = false;
    }
  }

  bool canCall() {
    if (!CloUtil.isCloB) {
      return false;
    }

    if (!selectedDiscover) {
      return false;
    }

    if (Get.currentRoute != Routes.MAIN) {
      return false;
    }

    if (AppUser.inst.isVip.value) {
      return false;
    }
    if (_callCount > 2) {
      return false;
    }
    // if (SmartDialog.checkExist(tag: DialogTag.sigin.name)) {
    //   return false;
    // }
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (_lastCallTime > 0 && currentTimestamp - _lastCallTime < 2 * 60 * 1000) {
      return false;
    }
    return true;
  }
}
