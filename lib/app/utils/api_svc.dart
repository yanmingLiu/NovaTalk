import 'dart:convert';
import 'dart:io';
import 'package:novatalk/app/entities/price_config_bean.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:novatalk/app/configs/constans.dart';
import 'package:novatalk/app/entities/conversation_entity.dart';
import 'package:novatalk/app/entities/msg_answer.dart';
import 'package:novatalk/app/entities/msg_toys.dart';
import 'package:novatalk/app/entities/people_mask_entity.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/entities/role_tags_entity.dart';
import 'package:novatalk/app/entities/sku.dart';
import 'package:novatalk/app/entities/user_entity.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/device_info.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../configs/app_config.dart';
import '../deploy/app_deploy.dart';
import '../entities/api_response.dart';
import '../entities/caht_level_config.dart';
import '../entities/chat_anser_level.dart';
import '../entities/create_style_bean.dart';
import '../entities/gen_photo_result_bean.dart';
import '../entities/gen_resoult_bean.dart';
import '../entities/moment_bean.dart';
import '../entities/msg_clothing.dart';
import '../entities/msg_res.dart';
import '../entities/order_and.dart';
import '../entities/order_ios.dart';
import '../entities/prompt_bean.dart';
import '../entities/record_bean.dart';
import '../entities/und_history_bean.dart';
import '../entities/und_result_bean.dart';
import '../entities/und_style_bean.dart';
import 'clo_util.dart';
import 'package:adjust_sdk/adjust.dart';

import 'common_utils.dart';

import 'dart:async';
import 'dart:typed_data';

import 'crypto_interceptor.dart';
import 'cryptography.dart';

class DioHelper {
  static final _instance = DioHelper._();
  late final Dio _dio;

  DioHelper._() {
    final headers = {
      'Content-Type': 'application/json',
      // 添加语言
      'lang': Get.locale?.languageCode ?? 'en',
    };
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: headers,
        receiveDataWhenStatusError: true,
        connectTimeout: 30.seconds,
        receiveTimeout: 100.seconds,
        responseType: isConfuse ? ResponseType.plain : ResponseType.json,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final deviceId = await DeviceInfo.deviceId();
          final version = await DeviceInfo.version();
          options.headers.addAll({
            'version': version,
            if (isConfuse) ...{
              AppConfig.prefix: Cryptology.encryptAES(deviceId),
              '${AppConfig.prefix}p': AppConfig.platform,
            } else ...{
              'device-id': deviceId,
              'platform': AppConfig.platform,
            },
          });
          return handler.next(options);
        },
      ),
    );
    if (isConfuse) {
      _dio.interceptors.add(CryptoInterceptor());
    }
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
      ),
    );
  }

  static Dio get dio => _instance._dio;
}

extension ExResponse on Response {
  bool get isOk {
    return statusCode! >= 200 && statusCode! < 300;
  }
}

class ApiSvc {
  ApiSvc._();

  static Map<String, dynamic> get _sqp => CloUtil.isCloB ? {'v': 'C001'} : {};

  static Future<UserEntity?> register() async {
    try {
      final deviceId = await DeviceInfo.deviceId();
      var res = await DioHelper.dio.post(
        AppDeploy.register,
        data: {"device_id": deviceId, "platform": AppConfig.platform},
      );
      var user = UserEntity.fromJson(res.data);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<UserEntity?> getUserInfo() async {
    try {
      final deviceId = await DeviceInfo.deviceId();
      final res = await DioHelper.dio.get(
        AppDeploy.getUserInfo,
        queryParameters: {'device_id': deviceId},
      );
      var user = UserEntity.fromJson(res.data);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<RoleEntity?> getRoleList({
    required int page,
    required int size,
    String? rendStyl,
    String? name,
    bool? videoChat,
    bool? genImg,
    bool? genVideo,
    bool? dress,
    List<int>? tags,
    bool? forYou,
  }) async {
    try {
      var data = {'page': page, 'size': size, 'platform': AppConfig.platform};
      if (rendStyl != null) {
        data['render_style'] = rendStyl;
      }
      if (videoChat != null) {
        data['video_chat'] = videoChat;
      }
      if (genImg != null) {
        data['gen_img'] = genImg;
      }
      if (genVideo != null) {
        data['gen_video'] = genVideo;
      }
      if (dress != null) {
        data['change_clothing'] = dress;
      }
      if (name != null) {
        data['name'] = name;
      }
      if (tags != null && tags.isNotEmpty) {
        data['tags'] = tags;
      }
      if (forYou != null) {
        data['forYou'] = forYou;
      }
      var res = await DioHelper.dio.post(
        AppDeploy.roleList,
        data: data,
        queryParameters: _sqp,
      );
      var role = RoleEntity.fromJson(res.data);
      return role;
    } catch (e) {
      return null;
    }
  }

  static Future<List<RoleTagsEntity>?> getRoleTags() async {
    try {
      var res = await DioHelper.dio.get(
        AppDeploy.roleTag,
        queryParameters: _sqp,
      );
      return (res.data as List).map((v) => RoleTagsEntity.fromJson(v)).toList();
    } catch (e) {
      return null;
    }
  }

  static Future<ConversationEntity?> sessionList(int page, int size) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.sessionList,
        data: {'page': page, 'size': size},
        queryParameters: _sqp,
      );
      return ConversationEntity.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }

  static Future<RoleEntity?> collectList(int page, int size) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.collectList,
        data: {'page': page, 'size': size},
        queryParameters: _sqp,
      );
      return RoleEntity.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserInfo(Map<String, String?> body) async {
    try {
      final res = await DioHelper.dio.post(
        AppDeploy.updateUserInfo,
        data: body,
      );
      return res.data['data'];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateEventParams({
    bool? autoTranslate,
    String? lang,
  }) async {
    try {
      String deviceId = await DeviceInfo.deviceId();
      final adid = await Adjust.getAdid();

      Map<String, dynamic> data = {
        if (!adid.isVoid) 'adid': adid,
        'device_id': deviceId,
        'platform': AppConfig.platform,
      };

      if (Platform.isIOS) {
        String? idfa = await Adjust.getIdfa();
        data['idfa'] = idfa;
      } else if (Platform.isAndroid) {
        final gpsAdid = await Adjust.getGoogleAdId();
        data['gps_adid'] = gpsAdid;
      }

      if (autoTranslate != null) {
        data['auto_translate'] = autoTranslate;
      }
      if (lang != null) {
        data['target_language'] = lang;
      }

      data['source_language'] = 'en';
      data['time_zone'] = formatTimeZoneOffset(DateTime.now().timeZoneOffset);

      var result = await DioHelper.dio.post(AppDeploy.eventParams, data: data);

      return result.data;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Sku>?> getSkuList() async {
    try {
      final response = await DioHelper.dio.get(AppDeploy.skuList);
      final res = ApiResponse.fromJsonByList<Sku>(
        response.data,
        decodeJson: Sku.fromJson,
      );
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> verifyIosOrder({
    required int orderId,
    required String? receipt,
    required String skuId,
    required String? transactionId,
    required String? purchaseDate,
    bool? dres,
    bool? createImg,
    bool? createVideo,
  }) async {
    final userId = AppUser.inst.user?.id;
    if (userId == null || userId.isEmpty) return false;

    var chooseEnv = isAppDebug ? false : true;
    final idfa = await Adjust.getIdfa();
    final adid = await Adjust.getAdid();
    try {
      var params = <String, dynamic>{
        'order_id': orderId,
        'user_id': userId,
        'receipt': receipt,
        'choose_env': chooseEnv,
        'idfa': idfa,
        'adid': adid,
        'sku_id': skuId,
        'transaction_id': transactionId,
        'purchase_date': purchaseDate,
      };
      if (dres != null) {
        params['dres'] = dres;
      }
      if (createImg != null) {
        params['create_img'] = createImg;
      }
      if (createVideo != null) {
        params['create_video'] = createVideo;
      }

      var res = await DioHelper.dio.post(
        AppDeploy.verifyIosReceipt,
        data: params,
      );
      if (res.isOk) {
        var data = ApiResponse.fromJson(res.data);
        if (data.code == 0 || data.code == 200) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future verifyAndOrder({
    required String originalJson,
    required String purchaseToken,
    required String skuId,
    required String orderType,
    required orderId,
    bool? dres,
    bool? createImg,
    bool? createVideo,
  }) async {
    try {
      final userId = AppUser.inst.user?.id;
      if (userId == null || userId.isEmpty) return false;
      String androidId = await DeviceInfo.deviceId(isOrigin: true);
      final adid = await Adjust.getAdid();
      final gpsAdid = await Adjust.getGoogleAdId();

      var body = <String, dynamic>{
        'original_json': originalJson,
        'purchase_token': purchaseToken,
        'order_type': orderType,
        'sku_id': skuId,
        'order_id': orderId,
        'android_id': androidId,
        'gps_adid': gpsAdid,
        'adid': adid,
        'user_id': userId,
      };
      if (dres != null) {
        body['dres'] = dres;
      }
      if (createImg != null) {
        body['create_img'] = createImg;
      }
      if (createVideo != null) {
        body['create_video'] = createVideo;
      }

      var res = await DioHelper.dio.post(AppDeploy.verifyAndOrder, data: body);
      if (res.isOk) {
        final data = ApiResponse.fromJson(res.data);
        if (data.code == 0 || data.code == 200) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future makeIosOrder({
    required String orderType,
    required String skuId,
    bool? createImg,
    bool? createVideo,
  }) async {
    try {
      final userId = AppUser.inst.user?.id;
      if (userId == null || userId.isEmpty) return null;

      String deviceId = await DeviceInfo.deviceId();

      var body = {
        'user_id': userId,
        'sku_id': skuId,
        'order_type': orderType,
        'device_id': deviceId,
        "create_img": createImg,
        "create_video": createVideo,
      };

      var res = await DioHelper.dio.post(AppDeploy.createIosOrder, data: body);
      if (res.isOk) {
        final result = ApiResponse.fromJson(
          res.data,
          decodeJson: OrderIos.fromJson,
        );
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future makeAndOrder({
    required String orderType,
    required String skuId,
    bool? createImg,
    bool? createVideo,
  }) async {
    try {
      final userId = AppUser.inst.user?.id;
      if (userId == null || userId.isEmpty) return null;

      String deviceId = await DeviceInfo.deviceId();

      var body = {
        'device_id': deviceId,
        'platform': AppConfig.platform,
        'order_type': orderType,
        'sku_id': skuId,
        'user_id': userId,
        "create_img": createImg,
        "create_video": createVideo,
      };

      var res = await DioHelper.dio.post(AppDeploy.createAndOrder, data: body);

      if (res.isOk) {
        var result = ApiResponse.fromJson(
          res.data,
          decodeJson: OrderAnd.fromJson,
        );
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> getDailyReward() async {
    try {
      var result = await DioHelper.dio.post(AppDeploy.signIn);
      final res = ApiResponse.fromJson(result.data);
      if (res.code == 0 || res.code == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<RoleRecords?> loadRoleById(String roleId) async {
    try {
      var qp = _sqp;
      qp['id'] = roleId;
      var res = await DioHelper.dio.get(
        AppDeploy.getRoleById,
        queryParameters: qp,
      );
      if (res.isOk) {
        var role = RoleRecords.fromJson(res.data);
        return role;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ConversationRecords?> addSession(String roleId) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.addSession,
        queryParameters: {'charId': roleId},
      );
      if (res.isOk) {
        return ConversationRecords.fromJson(res.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<ChatLevelConfig>?> getChatLevelConfig() async {
    try {
      var result = await DioHelper.dio.get(AppDeploy.chatLevelConfig);
      final list = result.data;
      if (list is List) {
        final datas = list.map((v) => ChatLevelConfig.fromJson(v)).toList();
        return datas;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ChatAnserLevel?> fetchChatLevel({
    required String charId,
    required String userId,
  }) async {
    try {
      var qb = _sqp;
      qb['charId'] = charId;
      qb['userId'] = userId;

      var result = await DioHelper.dio.post(
        AppDeploy.chatLevel,
        queryParameters: qb,
      );
      if (result.isOk) {
        var res = ApiResponse.fromJson(
          result.data,
          decodeJson: ChatAnserLevel.fromJson,
        );
        return res.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future consumeReq(int gems, String name) async {
    // 使用公钥加密消息
    final uid = AppUser.inst.user?.id;
    if (uid == null || uid.isEmpty) return 0;
    final signature = await getApiSignature();

    var body = <String, dynamic>{
      'signature': signature,
      'id': uid,
      'gems': gems,
      'description': name,
    };

    try {
      var res = await DioHelper.dio.post(
        AppDeploy.minusGems,
        data: body,
        queryParameters: _sqp,
      );
      if (res.isOk) {
        return res.data;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future getApiSignature() async {
    final uid = AppUser.inst.user?.id;
    if (uid == null || uid.isEmpty) return null;
    var pemPublicKey =
        '${'-----BEGIN PUBLIC KEY-----\n${AppConfig.consumeAuthKey}'}\n-----END PUBLIC KEY-----';

    final parser = RSAKeyParser();
    final RSAPublicKey publicKey = parser.parse(pemPublicKey) as RSAPublicKey;
    final encrypter = Encrypter(
      RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1),
    );
    final encrypted = encrypter.encrypt(uid);
    return encrypted.base64;
  }

  static Future<MsgRes?> messageList(int page, int pageSize, String? id) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.messageList,
        data: {'page': page, 'size': pageSize, 'conversation_id': id},
        queryParameters: _sqp,
      );
      if (res.isOk) {
        var data = MsgRes.fromJson(res.data);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<MsgToys>?> getToysConfigs() async {
    try {
      var result = await DioHelper.dio.get(AppDeploy.giftConfig);
      if (result.data is List) {
        final list = (result.data as List)
            .map((e) => MsgToys.fromJson(e))
            .toList();
        return list;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<MsgClothing>?> getClotheConfigs() async {
    try {
      var result = await DioHelper.dio.get(AppDeploy.changeConfig);
      if (result.data is List) {
        final list = (result.data as List)
            .map((e) => MsgClothing.fromJson(e))
            .toList();
        return list;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Stream<String>> subStream({
    required String requestUrl,
    Map? body,
  }) async {
    var response = await DioHelper.dio.post(
      requestUrl,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          'device-id': DeviceInfo.deviceId(),
          'platform': AppConfig.platform,
        },
      ),
      data: body,
    );
    Stream<Uint8List> byteStream = response.data.stream;
    return byteStream
        .map((chunk) => chunk.toList())
        .transform(utf8.decoder)
        .transform(const LineSplitter());
  }

  static Future cancelCollectRole(String roleId) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.cancelCollectRole,
        data: {'character_id': roleId},
      );
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future collectRole(String roleId) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.collectRole,
        data: {'character_id': roleId},
      );
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveMsgTrans({
    required String id,
    required String text,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.saveMsg,
        data: {'translate_answer': text, 'id': id},
      );
      return result.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<void> autoTranslate({required bool autoTranslate}) async {}

  static Future<String?> translateText(
    String content, {
    String? sl = 'en',
    String? tl,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.translate,
        data: {
          'content': content,
          'source_language': sl,
          'target_language': tl ?? Get.deviceLocale?.languageCode,
        },
      );
      final res = ApiResponse.fromJson(result.data);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future<Msg?> sendClothes({
    required String convId,
    required int id,
    required String roleId,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.sendClothes,
        data: {'model_id': roleId, 'id': id, 'conversation_id': convId},
      );
      var res = ApiResponse.fromJson(result.data, decodeJson: Msg.fromJson);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static Future<Msg?> sendToys({
    required String convId,
    required int id,
    required String roleId,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.sendToy,
        data: {'model_id': roleId, 'id': id, 'conversation_id': convId},
      );
      var res = ApiResponse.fromJson(result.data, decodeJson: Msg.fromJson);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  static buildParms({
    required String charId,
    required int conversationId,
    required String uid,
    String? message,
    String? msgId,
  }) {
    return {
      'character_id': charId,
      'conversation_id': conversationId,
      'message': message,
      'msg_id': msgId,
      'user_id': uid,
      'auto_translate': true,
      'target_language': AppUser.inst.targetLanguage.value.value ?? 'en',
    };
  }

  static Future<ApiResponse<Msg>?> sendMsg({
    required String charId,
    required int conversationId,
    required String uid,
    required String content,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.sendMsg,
        data: buildParms(
          charId: charId,
          conversationId: conversationId,
          uid: uid,
          message: content,
        ),
      );
      var response = ApiResponse.fromJson(
        result.data,
        decodeJson: Msg.fromJson,
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<ApiResponse<Msg>?> continueMsg(
    String charId,
    int conversationId,
    String uid,
  ) async {
    var result = await DioHelper.dio.post(
      AppDeploy.continueWrite,
      data: buildParms(
        charId: charId,
        conversationId: conversationId,
        uid: uid,
      ),
    );
    var response = ApiResponse.fromJson(result.data, decodeJson: Msg.fromJson);
    return response;
  }

  static Future<ApiResponse<Msg>?> refreshMsg(
    String charId,
    int conversationId,
    String uid,
    String msgId,
  ) async {
    var result = await DioHelper.dio.post(
      AppDeploy.resendMsg,
      data: buildParms(
        charId: charId,
        conversationId: conversationId,
        uid: uid,
        msgId: msgId,
      ),
    );
    var response = ApiResponse.fromJson(result.data, decodeJson: Msg.fromJson);
    return response;
  }

  static Future editMsg({String? msgId, required String newValue}) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.editMsg,
        data: {'answer': newValue, 'id': msgId},
      );
      return ifFailToVipOrGem(result.data);
    } catch (e) {
      return false;
    }
  }

  static bool ifFailToVipOrGem(
    Map<String, dynamic> result, {
    dynamic from = VipFrom.send,
  }) {
    var res = ApiResponse.fromJson(result);
    bool success = res.success == true;
    if (!success) {
      if (from is VipFrom) {
        pushVip(from);
      } else if (from is ConsumeFrom) {
        pushGem(from);
      }
    }
    return success;
  }

  static Future deleteSession(int id) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.deleteSession,
        queryParameters: {'id': id.toString()},
      );
      return res.isOk;
    } catch (e) {
      return false;
    }
  }

  static Future<ConversationRecords?> resetSession(int id) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.resetSession,
        queryParameters: {'conversationId': id.toString()},
      );
      if (res.isOk) {
        return ConversationRecords.fromJson(res.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future editScenario(String sessionId, roleId, String txt) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.editScene,
        data: {
          'conversation_id': sessionId,
          'character_id': roleId,
          'scene': txt,
        },
      );
      return ifFailToVipOrGem(result.data);
    } catch (e) {
      return false;
    }
  }

  static Future setChatMode(String sessionId, String val) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.editMode,
        data: {'id': sessionId, 'chat_model': val},
      );
      return ApiResponse.fromJson(result.data).success;
    } catch (e) {
      return false;
    }
  }

  static Future<List<PeopleMaskEntity>> getUserMaskList() async {
    var result = await DioHelper.dio.post(
      AppDeploy.getMaskList,
      data: {'page': 1, 'size': 999},
    );

    var peopleList = RecordBean.fromJsonByList(
      result.data,
      decodeJson: PeopleMaskEntity.fromJson,
    );
    return peopleList.records ?? [];
  }

  static Future changeMask(String? conversionId, String selectedMaskId) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.changeMask,
        data: {'conversation_id': conversionId, 'profile_id': selectedMaskId},
      );
      return ifFailToVipOrGem(result.data);
    } catch (e) {
      return false;
    }
  }

  static Future<PriceConfigBean?> getPriceConfig() async {
    try {
      var result = await DioHelper.dio.get(AppDeploy.getPriceConfig);
      return PriceConfigBean.fromJson(result.data);
    } catch (e) {
      return null;
    }
  }

  static Future createOrEditMask({
    String? maskId,
    required String name,
    required int gender,
    required String age,
    required String description,
    required String otherInfo,
    required bool isEdit,
  }) async {
    try {
      var result = await DioHelper.dio.post(
        isEdit ? AppDeploy.editMask : AppDeploy.designMask,
        data: {
          'id': maskId,
          'profile_name': name,
          'age': age.val,
          'gender': gender,
          'description': description,
          'other_info': otherInfo,
          'user_id': AppUser.inst.user?.id,
        },
      );
      return ifFailToVipOrGem(result.data, from: ConsumeFrom.mask);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteMask(String id) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.deleteMask,
        queryParameters: {'id': id},
      );
      var res = ApiResponse.fromJson(result.data);
      return res.success == true;
    } catch (e) {
      return false;
    }
  }

  static Future<MsgAnswer?> sendVoiceChatMsg({
    required String roleId,
    required String userId,
    required String nickName,
    required String message,
    String? msgId,
  }) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.voiceChat,
        data: {
          'char_id': roleId,
          'user_id': userId,
          'nick_name': nickName,
          'message': message,
          if (msgId?.isNotEmpty == true) 'msg_id': msgId,
        },
        queryParameters: _sqp,
      );
      if (res.isOk) {
        return MsgAnswer.fromJson(res.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future unlockImageReq(int imageId, String modelId) async {
    try {
      var result = await DioHelper.dio.post(
        AppDeploy.unlockImage,
        data: {'image_id': imageId, 'model_id': modelId},
      );

      return result.data;
    } catch (e) {
      return false;
    }
  }

  static Future<RoleRecords?> splashRandomRole() async {
    try {
      var res = await DioHelper.dio.get(
        AppDeploy.splashRandomRole,
        queryParameters: _sqp,
      );
      if (res.isOk) {
        var result = ApiResponse.fromJson(
          res.data,
          decodeJson: RoleRecords.fromJson,
        );
        return result.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAppLang() async {
    try {
      var result = await DioHelper.dio.get(AppDeploy.supportLang);
      var res = ApiResponse.fromJson(result.data);
      if (res.data != null) {
        return res.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<UndStyleBean>> getUndStyles() async {
    try {
      final res = await DioHelper.dio.post(
        AppDeploy.undrStyles,
        queryParameters: _sqp,
      );
      if (res.isOk) {
        var r = ApiResponse.fromJsonByList<UndStyleBean>(
          res.data,
          decodeJson: UndStyleBean.fromJson,
        );
        return r.data ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List?> getUndressHistory({String? roleId}) async {
    try {
      var resp = await DioHelper.dio.post(
        AppDeploy.getUndressHistory,
        data: {'character_id': roleId},
      );
      var undHistory = RecordBean.fromJsonByList(
        resp.data,
        decodeJson: UndHistoryBean.fromJson,
      );
      return undHistory.records;
    } catch (e) {}
    return null;
  }

  static Future<UndResultBean?> undressOperation({
    required Map<String, dynamic> formData,
    required String url,
  }) async {
    final resp = await DioHelper.dio.post(
      url,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      data: FormData.fromMap(formData),
    );
    if (resp.data != null) {
      return UndResultBean.fromJson(resp.data);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUndressResult(
    String taskId, {
    required String url,
  }) async {
    var resp = await DioHelper.dio.post(
      url,
      queryParameters: {'taskId': taskId},
    );
    return resp.data;
  }

  static Future<List<MomentBean>?> getMomentsList({
    required int page,
    required int size,
  }) async {
    try {
      var res = await DioHelper.dio.post(
        AppDeploy.momentsList,
        data: {
          'page': page,
          'size': size,
          'hide_character': CloUtil.isCloB ? true : false,
        },
        queryParameters: _sqp,
      );
      if (res.isOk) {
        final bean = RecordBean.fromJsonByList<MomentBean>(
          res.data,
          decodeJson: MomentBean.fromJson,
        );
        return bean.records ?? [];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<CreateStyleBean>> getCreationStyleOptions() async {
    final res = await DioHelper.dio.get(AppDeploy.getCreationStyleOptions);
    if (res.isOk) {
      final bean = ApiResponse.fromJsonByList<CreateStyleBean>(
        res.data,
        decodeJson: CreateStyleBean.fromJson,
      );
      return bean.data ?? [];
    }
    return [];
  }

  static Future<PromptBean?> getPresetPrompt() async {
    final res = await DioHelper.dio.get(AppDeploy.getPresetPrompt);
    if (res.isOk) {
      final result = ApiResponse.fromJson<PromptBean>(
        res.data,
        decodeJson: PromptBean.fromJson,
      );
      return result.data;
    }
    return null;
  }

  static Future<ApiResponse?> genAiPhoto({
    required int styleId,
    required int imgCount,
    required String describeImg,
    required String imageRatio,
  }) async {
    Map<String, dynamic> params = {
      "style_id": styleId,
      'img_count': imgCount,
      'describe_img': describeImg,
      'image_ratio': imageRatio,
    };
    try {
      final res = await DioHelper.dio.post(AppDeploy.genAiPhoto, data: params);
      if (res.isOk) {
        final result = ApiResponse.fromJson(res.data);
        if (result.success == true) {
          AppUser.inst.refreshUser();
        }
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //0=图生图, 1=图生视频, 2=文生图，不传则查询全部
  static Future<List<GenPhotoResultBean>> getCreations() async {
    final res = await DioHelper.dio.post(
      AppDeploy.aiPhotoHistory,
      data: {'page': 0, 'size': 1000},
    );

    if (res.isOk) {
      final result = ApiResponse.fromJson(res.data);
      final records = RecordBean.fromJsonByList<GenPhotoResultBean>(
        result.data,
        decodeJson: GenPhotoResultBean.fromJson,
      );
      return records.records ?? [];
    }
    return [];
  }

  static Future<bool> getGenImg(String taskId) async {
    final res = await DioHelper.dio.get(
      AppDeploy.getGenImg,
      queryParameters: {'id': taskId},
    );
    final result = ApiResponse.fromJson(
      res.data,
      decodeJson: GenResultBean.fromJson,
    );
    if (result.code != 200) {
      throw Exception(result.message);
    }
    return result.success == true &&
        result.data?.imgs != null &&
        result.data!.imgs!.length > 0;
  }
}
