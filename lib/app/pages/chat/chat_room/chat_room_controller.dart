import 'dart:async';

import 'package:novatalk/app/pages/chat/chat_room/vip_role_lock.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_config.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/entities/api_response.dart';
import 'package:novatalk/app/entities/conversation_entity.dart';
import 'package:novatalk/app/entities/msg_res.dart';
import 'package:novatalk/app/entities/role_entity.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/utils/storage_util.dart';
import 'package:novatalk/generated/assets.dart';

import '../../../../generated/locales.g.dart';
import '../../../configs/constans.dart';
import '../../../entities/caht_level_config.dart';
import '../../../entities/chat_anser_level.dart';
import '../../../entities/msg_clothing.dart';
import '../../../entities/msg_toys.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/download_util.dart';
import '../../../utils/log/log_event.dart';
import '../../../utils/trans_tool.dart';
import '../../../widgets/common_widget.dart';
import '../../gem/gem_view.dart';
import '../../undr/ctls/undress_page_controller.dart';
import '../../vip/vip_view.dart';
import '../chat_controller.dart';
import 'chat_level_up_dialog.dart';

Future<void> pushChatRoom(String? roleId, {bool showLoading = true}) async {
  if (roleId == null) {
    SmartDialog.showToast('roleId error');
    return;
  }
  try {
    if (showLoading) {
      SmartDialog.showLoading();
    }

    // 使用 Future.wait 来同时执行查角色和查会话
    var results = await Future.wait([
      ApiSvc.loadRoleById(roleId), // 查角色
      ApiSvc.addSession(roleId), // 查会话
    ]);

    var role = results[0];
    var session = results[1];

    // 检查角色和会话是否为 null
    if (role == null) {
      dismissAndShowMsg(LocaleKeys.roleNot.tr);
      return;
    }
    if (session == null) {
      dismissAndShowMsg(LocaleKeys.sessionNot.tr);
      return;
    }

    SmartDialog.dismiss();
    Get.toNamed(
      Routes.CHAT_ROOM,
      arguments: {'role': role, 'session': session},
    );
  } catch (e) {
    SmartDialog.dismiss();
    SmartDialog.showNotify(msg: e.toString(), notifyType: NotifyType.error);
  }
}

class ChatRoomController extends GetxController
    with MxPageData<Msg>, SubPacker {
  bool _isChatLevelDialogVisible = false;
  late RoleRecords role = Get.arguments['role'];
  late ConversationRecords session = Get.arguments['session'];

  Rx<ChatAnserLevel?> chatLevel = Rx<ChatAnserLevel?>(null);
  List<ChatLevelConfig> chatLevelConfigs = [];
  final inputTags = [].obs;

  // 相册变动
  var roleImagesChanged = 0.obs;

  bool isNewChat = false;
  bool isLock = false;

  late final chatMode = (session.chatModel ?? ChatMode.short.val).obs;

  // 获取玩具 衣服列表
  List<MsgToys>? toysConfigs;
  List<MsgClothing>? clotheConfigs;

  bool isReceiving = false;
  var tmpSendId = 'tmpSendId';
  Msg? tmpSendMsg;

  static const kTagNormal = 'TEXT-LOCK:NORMAL';
  static const kTagPrivate = 'TEXT-LOCK:PRIVATE';

  @override
  void onInit() {
    super.onInit();
    loadChatLevel();
    setupTease();
    loadMsg();
    loadToysAndClotheConfigs();
  }

  Future<void> updateSession() async {
    var session = await ApiSvc.addSession(role.id.val);
    if (session != null) {
      this.session = session;
    }
  }

  Future<void> loadToysAndClotheConfigs() async {
    if (toysConfigs != null && clotheConfigs != null) return;
    toysConfigs = await ApiSvc.getToysConfigs();
    clotheConfigs = await ApiSvc.getClotheConfigs();
  }

  Future loadMsg() async {
    addDefaultTips();
    var showTranslationMsgIds = StorageUtils.showTranslationMsgIds;
    final page = await ApiSvc.messageList(1, 10000, session.id);
    if (page != null) {
      final records = page.records ?? [];
      for (Msg element in records) {
        if (element.id != null) {
          if (showTranslationMsgIds.contains(element.id)) {
            element.showTranslate = true;
          }
        }
      }
      pageData.addAll(records);
    }
  }

  void addDefaultTips() {
    final tips = Msg();
    tips.source = MsgSource.tips;
    pageData.add(tips);

    var scenario = session.scene ?? role.scenario;

    if (scenario != null && scenario.isNotEmpty) {
      final intro = Msg();
      intro.source = MsgSource.scenario;
      intro.answer = scenario;
      pageData.add(intro);
    } else {
      if (role.aboutMe != null && role.aboutMe!.isNotEmpty) {
        final intro = Msg();
        intro.source = MsgSource.intro;
        intro.answer = role.aboutMe;
        pageData.add(intro);
      }
    }
    _addRandomGreetings();
  }

  Future<void> _addRandomGreetings() async {
    final greetings = role.greetings;
    final greetingsVoices = role.greetingsVoice;
    if (greetings == null || greetings.isEmpty) {
      return;
    }
    int randomIndex = randomNumber(max: greetings.length - 1);
    var str = greetings[randomIndex];

    String? voiceUrl;
    int voiceDur = 0;
    if (greetingsVoices != null && greetingsVoices.length > randomIndex) {
      final voice = greetingsVoices[randomIndex];
      voiceUrl = voice.url;
      voiceDur = voice.duration ?? 0;

      if (session.id != null) {
        final isExist = StorageUtils.isSessionExist(session.id.toInt);
        if (isExist) {
          isNewChat = false;
        } else {
          isNewChat = true;
          if (voiceUrl != null && voiceUrl.isNotEmpty) {
            DownloadUtil.download(voiceUrl);
          }
          StorageUtils.addSessionId(session.id!.toInt);
        }
      }
    }
    final msg = Msg();
    msg.id = '${DateTime.now().millisecondsSinceEpoch}';
    msg.answer = str;
    msg.voiceUrl = voiceUrl;
    msg.voiceDur = voiceDur;
    msg.source = MsgSource.welcome;
    pageData.add(msg);
  }

  void setupTease() {
    inputTags.clear();

    if (CloUtil.isCloB) {
      inputTags.add({
        'id': 0,
        'name': 'Tease',
        'list': [
          LocaleKeys.thi1.tr,
          LocaleKeys.thi2.tr,
          LocaleKeys.thi3.tr,
          LocaleKeys.thi4.tr,
          LocaleKeys.thi5.tr,
          LocaleKeys.thi6.tr,
          LocaleKeys.thi7.tr,
          LocaleKeys.thi8.tr,
          LocaleKeys.thi9.tr,
          LocaleKeys.thi10.tr,
          LocaleKeys.thi11.tr,
          LocaleKeys.thi12.tr,
          LocaleKeys.thi13.tr,
          LocaleKeys.thi14.tr,
        ],
      });
    }

    // inputTags.add({'id': 3, 'name': LocaleKeys.mask, 'list': []});

    if (kDebugMode) {
      inputTags.add({'id': 1, 'name': LocaleKeys.dress, 'list': []});
    } else if (CloUtil.isCloB) {
      final count = StorageUtils.sendMsgCount;
      if (count >= AppConfig.undNum) {
        inputTags.add({'id': 1, 'name': LocaleKeys.dress, 'list': []});
      }
    }
  }

  @override
  void onReady() {
    showVipRoleLockDialog();
    super.onReady();
  }

  void showVipRoleLockDialog() {
    final vip = AppUser.inst.isVip.value;
    if (role.vip == true && !vip) {
      Get.dialog(
        barrierDismissible: false,
        PopScope(
          onPopInvoked: (didPop) {},
          child: Center(
            child: buildTheme1SheetRootWidget(
              child: VipRoleLock(),
              onClose: () {
                Get.closeDialog();
                Get.back();
              },
            ),
          ),
        ),
      );
      addSub(
        AppUser.inst.isVip.listen((v) {
          if (v) {
            Get.closeDialog();
          }
        }),
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
    cancelSubs();
    $<ChatController>()?.refreshData();
  }

  void loadChatLevel() async {
    try {
      chatLevelConfigs = await AppUser.inst.fetchChatLevelConfigs();
      final roleId = role.id;
      final userId = AppUser.inst.user?.id;
      if (roleId == null || userId == null) {
        return;
      }
      var res = await ApiSvc.fetchChatLevel(charId: roleId, userId: userId);
      chatLevel.value = res;
    } catch (e) {
      goPrint('loadChatLevel error:$e');
    }
  }

  Future<void> sendMsg(String content) async {
    bool canSend = await canSendMsg(content);
    if (!canSend) {
      return;
    }
    final charId = role.id;
    final conversationId = session.id.toInt;
    final uid = AppUser.inst.user?.id;
    if (charId == null || uid == null) {
      return;
    }

    final msg = Msg(
      id: tmpSendId,
      question: content,
      userId: AppUser.inst.user?.id,
      conversationId: conversationId,
      characterId: charId,
      onAnswer: true,
    );
    msg.source = MsgSource.sendText;
    pageData.add(msg);
    tmpSendMsg = msg;

    isReceiving = true;
    logEvent('c_chat_send');
    var response = await ApiSvc.sendMsg(
      charId: charId,
      conversationId: conversationId,
      uid: uid,
      content: content,
    );
    if (response != null) {
      progressResponse(response);
    }
    // listenStream(strm);
  }

  Future<void> progressResponse(ApiResponse<Msg> response) async {
    SmartDialog.dismiss(status: SmartStatus.loading);
    if (response.code == 20003) {
      // Insufficient gold
      if (tmpSendMsg != null) {
        pageData.removeLast();
      }
      isReceiving = false;
      showNotEnough();
      return;
    }
    if (response.success == false) {
      SmartDialog.showToast(LocaleKeys.occurredTips.tr);
      return;
    }
    var msg = response.data!;
    isLock = msg.textLock == LockLevel.private.value;

    if (msg.conversationId == session.id.toInt) {
      /// 修改发送消息的状态
      tmpSendMsg?.onAnswer = false;
      if (isLock) {
        msg.typewriterAnimated = AppUser.inst.isVip.value;
        if (!AppUser.inst.isVip.value) {
          isReceiving = false;
        }
      } else {
        msg.typewriterAnimated = true;
      }
      // 删除最后一条tmpSendMsg
      if (pageData.isNotEmpty &&
          pageData.last.id == tmpSendId &&
          msg.question == pageData.last.question) {
        pageData.removeLast();
      }
      final index = pageData.indexOf(msg);
      if (index != -1) {
        pageData[index] = msg;
      } else {
        pageData.add(msg);
      }
      _checkChatLevel(msg);
    }
    AppUser.inst.refreshUser();
    tmpSendMsg = null;
  }

  Future<void> showNotEnough() async {
    await SmartDialog.showToast(LocaleKeys.creditsNotEnough.tr);
    pushVip(VipFrom.send);
  }

  // void listenStream(Stream<String>? stream) async {
  //   subscription?.cancel();
  //   subscription = stream?.listen(
  //     (data) {
  //       progressSSE(data);
  //     },
  //     onError: (e) {
  //       SmartDialog.showToast(LocaleKeys.occurredTips.tr);
  //     },
  //   );
  // }

  // void progressSSE(String data) async {
  //   goPrint('🤗 received  msg: $data');
  //   if (data.contains(kTagNormal)) {
  //     isLock = false;
  //   } else if (data.contains(kTagPrivate)) {
  //     isLock = true;
  //   }
  //   // 去掉换行符
  //   data = data.replaceAll(RegExp(r'[\r\n]+'), '');
  //
  //   if (data.contains('Insufficient gold')) {
  //     pageData.removeLast();
  //     pushGem(ConsumeFrom.send);
  //     return;
  //   }
  //
  //   if (data.contains('MEDIA START')) {
  //     SmartDialog.dismiss(status: SmartStatus.loading);
  //
  //     /// 修改发送消息的状态
  //     tmpSendMsg?.onAnswer = false;
  //
  //     final regex = RegExp(r'MEDIA START(.*?)MEDIA END', dotAll: true);
  //     final match = regex.firstMatch(data);
  //
  //     if (match != null) {
  //       String jsonString = match.group(1)!.trim();
  //       goPrint('Extracted JSON: $jsonString');
  //       Msg msg = Msg.fromRawJson(jsonString);
  //
  //       if (msg.conversationId == session.id.toInt) {
  //         if (isLock) {
  //           msg.typewriterAnimated = AppUser.inst.isVip.value;
  //         } else {
  //           msg.typewriterAnimated = true;
  //         }
  //         // 删除最后一条tmpSendMsg
  //         if (pageData.isNotEmpty &&
  //             pageData.last.id == tmpSendId &&
  //             msg.question == pageData.last.question) {
  //           pageData.removeLast();
  //         }
  //         final index = pageData.indexOf(msg);
  //         if (index != -1) {
  //           pageData[index] = msg;
  //         } else {
  //           pageData.add(msg);
  //         }
  //         _checkChatLevel(msg);
  //       }
  //     } else {
  //       goPrint('No match found for MEDIA START');
  //     }
  //
  //     isReceiving = false;
  //     AppUser.inst.refreshUser();
  //   }
  //   if (data.contains('EOF')) {
  //     goPrint('EOF received, clearing buffer and stopping listening');
  //   }
  //   tmpSendMsg = null;
  // }

  void _checkChatLevel(Msg msg) async {
    bool upgrade = msg.upgrade ?? false;
    int rewards = msg.rewards ?? 0;
    ChatAnserLevel? level = msg.appUserChatLevel;
    chatLevel.value = level;
    if (upgrade) {
      // 升级了
      await showChatLevelUp(rewards);

      if ((level?.level ?? 0) == 2 && !StorageUtils.showedHelpUsS1) {
        StorageUtils.showedHelpUsS1 = true;
        showHelpUs();
      }
    } else {
      checkSendCount();
    }
  }

  Future<void> showChatLevelUp(int rewards) async {
    // 防止重复弹出
    if (_isChatLevelDialogVisible) return;

    // 设置标记为显示中
    _isChatLevelDialogVisible = true;

    try {
      await _showLevelUpToast(rewards);
    } finally {
      _isChatLevelDialogVisible = false;
    }
    checkSendCount();
  }

  void checkSendCount() async {
    // showUndTips();
    // return;
    // 发送成功后，更新发送次数
    StorageUtils.sendMsgCount = StorageUtils.sendMsgCount + 1;
    setupTease();

    if (CloUtil.isCloB) {
      var count = StorageUtils.sendMsgCount;
      if (count == AppConfig.undNum) {
        await showUndTips();
      }
    }
    showHelpUsDialog();
  }

  Future<void> showUndTips() async {
    Get.bottomSheet(
      isScrollControlled: true,
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:  CrossAxisAlignment.end,
          children: [
            TapBox(
                 onTap: () {
                   Get.closeBottomSheet();
                },
                child: buildCloseIcon()),
            8.verticalSpace,
            Stack(
              children: [
                Assets.imagesBgkClotTips.iv(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocaleKeys.untie.tv(
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    20.verticalSpace,
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 190.w,
                        minHeight: 78.h
                      ),
                      child: LocaleKeys.clothes.tv(
                        textAlign: TextAlign.start,
                        style: tTheme.bodyLarge,
                      ),
                    ),
                    15.verticalSpace,
                    buildTheme3Btn(
                      bold: true,
                      onTap:  () {
                        Get.closeBottomSheet();
                        Get.toNamed(
                          Routes.UND,
                          arguments: UndressPageArgs(
                            characterId: role.id,
                            coverUrl: StorageUtils.chatBgImagePath.isVoid
                                ? session.avatar
                                : StorageUtils.chatBgImagePath,
                          ),
                        );
                      },
                      alignment:  Alignment.center,
                      title: LocaleKeys.tryNow.tr,
                    )
                  ],
                ).paddingAll(20.r),
              ],
            ),
            10.verticalSpace
          ],
        ).paddingSymmetric(horizontal: 20.w),
      )
    );
    return;
    await Theme1Dialog.showBottomOnlyBtn(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              15.horizontalSpace,
              LocaleKeys.untie.tv(
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              5.horizontalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Color(0xff85FFCD),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    AppConfig.kNS.tv(
                      style: tTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.verticalSpace,
          LocaleKeys.clothes.tv(
            textAlign: TextAlign.center,
            style: tTheme.bodyLarge,
          ),
        ],
      ),
      confirmText: LocaleKeys.tryNow.tr,
      onTap: () {
        Get.closeDialog();
        Get.toNamed(
          Routes.UND,
          arguments: UndressPageArgs(
            characterId: role.id,
            coverUrl: StorageUtils.chatBgImagePath.isVoid
                ? session.avatar
                : StorageUtils.chatBgImagePath,
          ),
        );
      },
    );
  }

  Future<void> _showLevelUpToast(int rewards) async {
    final toastMessage = LocaleKeys.levelTips.trParams({
      'rewards': rewards.toString(),
    });
    final completer = Completer<void>();

    await SmartDialog.showToast(
      toastMessage,
      debounce: true,
      alignment: Alignment.center,
      builder: (BuildContext context) => Container(
        height: 56.h,
        width: 98.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.imagesIcGem.iv(width: 24.w),
            5.horizontalSpace,
            Text(
              "+$rewards",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismiss: () async {
        await showGetGemSuccess(num: rewards.val);
        completer.complete();
      },
    );
    await completer.future;
  }

  Future<bool> canSendMsg(String text) async {
    if (isReceiving) {
      SmartDialog.showToast(LocaleKeys.waitMsg.tr, debounce: true);
      return false;
    }

    // Msg lastMsg = pageData.last;
    // if (lastMsg.typewriterAnimated) {
    //   SmartDialog.showToast(LocaleKeys.waitMsg.tr);
    //   return false;
    // }

    if (text.isEmpty) {
      SmartDialog.showToast(LocaleKeys.inputTips.tr);
      return false;
    }
    final roleId = role.id;
    if (roleId == null) {
      return false;
    }
    if (!AppUser.inst.isVip.value) {
      if (role.gems == true) {
        final flag = AppUser.inst.isBalanceEnough(ConsumeFrom.text);
        if (!flag) {
          showNotEnough();
          return false;
        }
      } else {
        /// 免费角色 - 最大免费条数
        final maxCount = AppConfig.maxFreeChatCount;
        final sendCount = StorageUtils.sendMsgCount;

        if (sendCount > maxCount) {
          Theme1Dialog.showBottomTwoBtn(
            content: LocaleKeys.freeTips,
            onConfirm: () {
              logEvent('t_chat_send');
              pushVip(VipFrom.send);
            },
          );
          return false;
        }
      }
    }
    return true;
  }

  void onTapImage(RoleRecordsImages image) {
    final imageUrl = image.imageUrl;
    if (imageUrl == null) {
      return;
    }
    Get.toNamed(Routes.IMAGEP_REVIEW, arguments: imageUrl);
  }

  Future<void> onTapUnlockImage(RoleRecordsImages image) async {
    final gems = image.gems ?? 0;
    if (AppUser.inst.balance.value < gems) {
      pushGem(ConsumeFrom.album);
      return;
    }

    final imageId = image.id;
    final modelId = image.modelId;
    if (imageId == null || modelId == null) {
      return;
    }

    SmartDialog.showLoading();
    final res = await ApiSvc.unlockImageReq(imageId, modelId);
    SmartDialog.dismiss();
    if (res) {
      // 创建一个新的 pic 列表
      final updatedImages = role.images?.map((i) {
        if (i.id == imageId) {
          return i.copyWith(unlocked: true);
        }
        return i;
      }).toList();

      // 更新 Role 对象
      role = role.copyWith(images: updatedImages);
      roleImagesChanged.value++;
      AppUser.inst.refreshUser();

      onTapImage(image);
    }
  }

  @override
  Future<List<Msg>> loadData() {
    // TODO: implement loadData
    throw UnimplementedError();
  }

  Future<void> translateMsg(Msg msg) async {
    final content = msg.answer;

    // 内容为空直接返回
    if (content == null || content.isEmpty) return;

    // 定义更新消息的方法
    Future<void> updateMessage({
      required bool showTranslate,
      String? translate,
    }) async {
      Set<String> ids = StorageUtils.showTranslationMsgIds;
      if (showTranslate) {
        ids.add(msg.id.val);
      } else {
        ids.remove(msg.id.val);
      }
      StorageUtils.showTranslationMsgIds = ids;
      msg.showTranslate = showTranslate;
      if (translate != null) {
        msg.translateAnswer = translate;

        ApiSvc.saveMsgTrans(id: msg.id ?? '', text: translate);
      }
      pageData.refresh();
    }

    // 根据状态处理逻辑
    if (msg.showTranslate == true) {
      await updateMessage(showTranslate: false);
    } else if (msg.translateAnswer != null) {
      await updateMessage(showTranslate: true);
      TransTool().handleTranslationClick();
    } else {
      logEvent('c_trans');
      if (msg.translateAnswer == null) {
        // 获取翻译内容
        SmartDialog.showLoading();
        String? result = await ApiSvc.translateText(content);
        SmartDialog.dismiss();
        // 更新消息并显示翻译
        await updateMessage(showTranslate: true, translate: result);
      } else {
        await updateMessage(showTranslate: true);
      }

      TransTool().handleTranslationClick();
    }
  }

  Future<void> continueMsg() async {
    isReceiving = true;
    SmartDialog.showLoading();
    var response = await ApiSvc.continueMsg(
      role.id!,
      session.id.toInt,
      (AppUser.inst.user?.id).val,
    );
    if (response != null) {
      progressResponse(response);
    }
  }

  Future<void> refreshMsg(Msg msg) async {
    isReceiving = true;
    SmartDialog.showLoading();
    var response = await ApiSvc.refreshMsg(
      role.id!,
      session.id.toInt,
      (AppUser.inst.user?.id).val,
      msg.id.val,
    );
    if (response != null) {
      progressResponse(response);
    }
  }

  Future<void> editMsg(Msg msg, String value) async {
    SmartDialog.showLoading();
    var bl = await ApiSvc.editMsg(msgId: msg.id, newValue: value);
    SmartDialog.dismiss();
    if (bl) {
      AppUser.inst.refreshUser();
      msg.answer = value;
      msg.showTranslate = false;
      msg.translateAnswer = null;
      pageData.refresh();
    }
  }

  Future deleteConv() async {
    SmartDialog.showLoading();
    var result = await ApiSvc.deleteSession(session.id.toInt);
    StorageUtils.removeSessionId(session.id.toInt);
    SmartDialog.dismiss();
    return result;
  }

  Future resetConv() async {
    SmartDialog.showLoading();
    var result = await ApiSvc.resetSession(session.id.toInt);
    SmartDialog.dismiss();
    if (result != null) {
      session = result;
      pageData.clear();
      addDefaultTips();
      return true;
    }
    return false;
  }

  Future<void> sendClothes(MsgClothing clothings) async {
    try {
      var balance = AppUser.inst.balance.value;
      var price = clothings.itemPrice ?? 0;
      if (balance < price) {
        pushGem(ConsumeFrom.gift_clo);
        return;
      }

      final convId = session.id;
      final id = clothings.id;
      final roleId = role.id;
      if (convId == null || id == null || roleId == null) {
        return;
      }
      Get.back();

      showClothesLoading();

      isReceiving = true;

      Msg? msg = await ApiSvc.sendClothes(
        convId: convId,
        id: id,
        roleId: roleId,
      );

      var imgUrl = msg?.giftImg;

      if (imgUrl != null) {
        Completer<void> completer = Completer<void>();
        final ExtendedNetworkImageProvider imageProvider =
            ExtendedNetworkImageProvider(imgUrl, cache: true);
        imageProvider
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener(
                (ImageInfo image, bool synchronousCall) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                },
                onError: (dynamic exception, StackTrace? stackTrace) {
                  if (!completer.isCompleted) {
                    completer.completeError(exception); // 加载失败时返回异常
                  }
                },
              ),
            );
        // 等待图片加载完成
        await completer.future;
      }
      isReceiving = false;

      if (msg != null) {
        pageData.add(msg);

        Get.toNamed(Routes.IMAGEP_REVIEW, arguments: imgUrl ?? '');

        AppUser.inst.refreshUser();
      } else {
        SmartDialog.showToast(LocaleKeys.occurredTips.tr);
      }
    } catch (e) {
      SmartDialog.showToast(LocaleKeys.occurredTips.tr);
    } finally {
      hiddenClothesLoading();
    }
  }

  Future<void> sendToy(MsgToys toy) async {
    try {
      var balance = AppUser.inst.balance.value;
      var price = toy.itemPrice ?? 0;
      if (balance < price) {
        pushGem(ConsumeFrom.gift_toy);
        return;
      }

      final convId = session.id;
      final giftId = toy.id;
      final roleId = role.id;
      if (convId == null || giftId == null || roleId == null) {
        return;
      }
      Get.back();

      Msg? msg = await ApiSvc.sendToys(
        convId: convId,
        id: giftId,
        roleId: roleId,
      );
      if (msg != null) {
        pageData.add(msg);
      }
      AppUser.inst.refreshUser();
    } catch (e) {
      SmartDialog.showToast(LocaleKeys.occurredTips.tr);
    }
  }

  Future<void> editScenario(String? txt) async {
    SmartDialog.showLoading();
    var bl = await ApiSvc.editScenario(session.id.val, role.id, txt ?? "");
    SmartDialog.dismiss();
    if (bl) {
      session.scene = txt;
      pageData.clear();
      addDefaultTips();
    }
  }

  Future<void> setChatMode() async {
    SmartDialog.showLoading();
    var bl = await ApiSvc.setChatMode(session.id.val, chatMode.value);
    SmartDialog.dismiss();
    if (bl) {
      SmartDialog.dismiss();
    }
  }

  Future<void> showHelpUsDialog() async {
    int sendMsgCount = StorageUtils.getRoleSendCount(role.id.val);
    sendMsgCount += 1;
    if (sendMsgCount == 2 && !StorageUtils.showedHelpUsS2) {
      StorageUtils.showedHelpUsS2 = true;
      await showHelpUs();
    }
    StorageUtils.roleSendCount(sendMsgCount, role.id.val);
  }
}
