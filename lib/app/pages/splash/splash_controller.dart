import 'dart:convert';
import 'dart:io';

import 'package:novatalk/generated/locales.g.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/utils/ad/ad_loader.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';

import '../../configs/app_config.dart';
import '../../configs/constans.dart';
import '../../routes/app_pages.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../utils/clo_util.dart';
import '../../utils/facebook_util.dart';
import '../../utils/log/svr_log_event.dart';
import '../../utils/purchase_helper.dart';
import '../../utils/storage_util.dart';
import '../../widgets/common_widget.dart';

class SplashController extends GetxController with SubPacker {
  @override
  void onInit() {
    super.onInit();
    initEasyRefresh();

    addSub(
      Connectivity().onConnectivityChanged.listen((status) async {
        if (!await canEnter() && kReleaseMode && !isAppDebug) {
          SmartDialog.showToast(LocaleKeys.occurredTips.tr);
          return;
        }
        if (status
            .where((element) => element != ConnectivityResult.none)
            .isNotEmpty) {
          Future.wait([
            initFireBase(),
            CloUtil.request(),
            getUserInfo(),
            logInstallEvent(),
            AppConfig.getAppLang(),
            AppConfig.loadToysAndClotheConfigs(),
            AppConfig.initAdjust(),
          ]).timeout(10.seconds).whenComplete(() async {
            Get.offAndToNamed(Routes.MAIN);
          });
          PurchaseHelper.inst.getProducts();
        }
      }),
    );
  }

  Future<bool> canEnter() async {
    final locale = Platform.localeName;
    final timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;

    // 检查设备当前的系统语言（如zh-Hans）和地区设置（如 CN、HK、MO）
    if (locale.containsIgnoreCase('zh') &&
            (locale.containsIgnoreCase('Hans') ||
                locale.containsIgnoreCase('_Hans')) ||
        locale.containsIgnoreCase('CN') ||
        locale.containsIgnoreCase('HK') ||
        locale.containsIgnoreCase('MO')) {
      return false;
    }
    // 检查设备时区是否为中国大陆、香港、澳门的时区
    final List<dynamic> chineseTimezones = jsonDecode(
      AppConfig.chineseTimezones,
    );
    for (final timezone in chineseTimezones) {
      if (timeZoneName.containsIgnoreCase(timezone)) {
        return false;
      }
    }

    return true;
  }

  @override
  void onClose() {
    super.onClose();
    cancelSubs();
  }

  void initEasyRefresh() {
    EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
      showMessage: false,
      showText: false,
      iconTheme: IconThemeData(color: Colors.white),
    );
    EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
      showMessage: false,
      showText: false,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  Future initFireBase() async {
    try {
      await FacebookSDKUtil.fireBaseInitialize();
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      FacebookSDKUtil.initializeWithRemoteConfig();
      loadNativeAd();
    } catch (e) {
      goPrint('FRC Error: $e');
    }
  }

  Future getUserInfo() async {
    await AppUser.inst.getUser();
  }

  Future<void> loadNativeAd() async {
    // if (Platform.isIOS) {
    //   if (AdLoader().nativeAd != null) {
    //     await AdLoader().nativeAdUtil.dispose();
    //   }
    //   AdLoader().loadNativeAd(placement: PlacementType.homelist);
    // }
  }

  Future<void> logInstallEvent() async {
    if (StorageUtils.firstLaunch) {
      SvrLogEvent().logInstallEvent();
      StorageUtils.firstLaunch = false;
    }
    SvrLogEvent().logSessionEvent();
  }
}
