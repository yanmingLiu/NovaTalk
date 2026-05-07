import 'dart:async';
import 'dart:io';

import 'package:novatalk/app/utils/common_utils.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/device_info.dart';
import 'package:flutter/foundation.dart' hide Key;

import '../entities/msg_clothing.dart';
import '../entities/msg_toys.dart';
import '../utils/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart' ;

const bool isAppDebug = true;
bool get isConfuse => !isAppDebug && kReleaseMode;

class AppConfig {
  AppConfig._();

  static const int maxFreeChatCount = 50;
  static const int undNum = 5;
  static const String appStoreId = "6760631814";
  static const String supportEmail = "anytalkk@proton.me";
  static const String privacy = "https://anytalkweb.com/privacy/";
  static const String terms = "https://anytalkweb.com/terms/";
  static const String adJustToken = "rs4j78tsurr4";
  static final String platform = Platform.isAndroid ? "any-android" : "any";
  static const String baseUrl = (isAppDebug
      ? "https://liuhaipeng3.powerfulclean.net"
      : "https://server.vxjxutosgintpfzu.com");
  static String prefix = isConfuse ? "vxjxutosgintpfzu" : "";

  // AES密钥(私钥) 和 IV(公钥)
  static final cryptology_key = Key.fromUtf8('wvmO2a3aeHpdtKkk');
  static final cryptology_iv = IV.fromUtf8('0PlNu8klKxMFbXbY');

  // test:ca-app-pub-3940256099942544/3986624511
  @visibleForTesting
  static String get nativeTestAdId => "ca-app-pub-3940256099942544/3986624511";
  static const String nativeDefaultAdId ="";

  // https://static.amorai.net/images/1926887945078358018.mp4
  static String get undressBeforeVideo => Cryptology.decryptAES("59e1d6923943c3394a5d0ffcfd5b0ddaf9d91f6c48300e6430f55f373cb76f44d455ed5d33014ce3d75cf99040310b577da04c324ca6768a36a3db0d666f68a0");

  // https://static.amorai.net/2025-06-11/20250611-180956.jpeg
  static String get undressBeforeImage => Cryptology.decryptAES("59e1d6923943c3394a5d0ffcfd5b0dda798a10857196492151ff0905b37c164c5e55401d892f35e524d8755ff64f8820f1fc57b9433c78cf19f4dbadf80b4dfd");

  // Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36
  static String get userAgent => Cryptology.decryptAES("69a0a7f643ae2e734690caf9f7a48903174934b4f8dc25cb0c2ee5615e445f19e2dc783285a0533de031ec33b268a14aecbc064a30fe5b86788cf7ebd5b28a058a70c94b5b08a0e503ab40af89d002b209bbda716bd6fbc66bb16031e191888c1abe44e0503e2ff9897fd8850858d35c07e60fc6a41b683622819dbfcc2cda49");

  //MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCLWMEjJb703WZJ5Nqf7qJ2wefSSYvbmQZM0CgHGrYstUaj4Mlz+P06mCqpVAYmyf3dJxLrEsUiobWvhi1Ut5W+PY0yrzEsIOJ5lJrIt1pm0/kcPsPj2d4cEl9S7DTEIJVQTGMzquAlhEkgbA0yDVXNtqqf4MECCADU/WM3WTCH2QIDAQAB
  static String get consumeAuthKey => Cryptology.decryptAES("ed84ec0daaa7edebe540599596e8b57142c78e291fe4de60586df8f5f19e9ffb779119dd300a4386d35ab8374e32b325fc5ffdca3d04f6d90c8c79b28fac55c4898b406b447c560a4cc1e85a5e1cae9c53fa7f7b075e4c666063768594e4474c9d7727087e2f8b8fe50a7dcabf647e8b23eda95b2bc972cf9915a27414c1cd122647e0dc006b2884e8617917b5daee85300ab773189d38c70f86d4b660b9dfe9bfdb278c559c1404ebba4d547e84f912eaba8d78a03f9c3269c6717a2c607275a75a98852748b15e07217d72ddaea2c8a2605a13c845007eed31c60c2326912c");
  // [\"Asia/Shanghai\",\"Shanghai\",\"Urumqi\",\"Chongqing\",\"Chungking\",\"Harbin\",\"Kashgar\",\"Beijing\",\"Hong_Kong\",\"Macau\",\"PRC\"]
  static String get chineseTimezones => Cryptology.decryptAES("64b11648e68aa0694a77a4fb8115588e89ed4fdb5936a4caf579b51997d1907cdc63f65d1cf17b014706bdfa5556e9125399f1dd28db61c67f82d1b782591591240a2f5c557fdd228b1d409a6dc695e7fce74dea58ce42c610ee2d2777cdf11ec1cabcf1fef9c0d52d0c11b7e78787be9949d5c04d57e0f088946ec9d949e28d");
  //   NSFW, BDSM
  static String get kNS => Cryptology.decryptAES("df98e6e8965fd0b0187e282834f8e8d3");
  static String get kBD => Cryptology.decryptAES("536ba65aa6b2cb62050b1de211f816e5");



  // 获取玩具 衣服列表
  static List<MsgToys>? toysConfigs;
  static List<MsgClothing>? clotheConfigs;

  static Future<void> loadToysAndClotheConfigs() async {
    if (toysConfigs != null && clotheConfigs != null) return;
    toysConfigs = await ApiSvc.getToysConfigs();
    clotheConfigs = await ApiSvc.getClotheConfigs();
  }

  static Future<void> initAdjust() async {
    var deviceId = await DeviceInfo.deviceId(isOrigin: true);
    // Adjust
    AdjustEnvironment env = AdjustEnvironment.production;
    AdjustConfig config = AdjustConfig(adJustToken, env);
    config.logLevel = AdjustLogLevel.error;
    config.externalDeviceId = deviceId;

    config.deferredDeeplinkCallback = (String? uri) {
      // openApp(Uri.parse(uri));
    };

    Adjust.initSdk(config);
  }

  static final Completer<Map<String, dynamic>> supportLang = Completer();

  static Future<void> getAppLang() async {
    var value = await ApiSvc.getAppLang();
    if (value != null) {
      supportLang.completeIfNotCompleted(value);
    }
  }
}
