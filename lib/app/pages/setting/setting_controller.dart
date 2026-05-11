import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/locales.g.dart';
import '../../configs/constans.dart';

import '../../utils/storage_util.dart';

class SettingController extends GetxController {
  //TODO: Implement SettingController

  final count = 0.obs;

  final chatBgImagePath = "".obs;

  @override
  void onInit() {
    super.onInit();
    chatBgImagePath.value = StorageUtils.chatBgImagePath;
  }

  void increment() => count.value++;

  Future<void> changeNickName(String newNickname) async {
    SmartDialog.showLoading();
    await AppUser.inst.updateUser(newNickname);
    SmartDialog.dismiss();
  }

  Future<void> autoTranslation(bool value) async {
    if (AppUser.inst.isVip.value) {
      SmartDialog.showLoading();
      await ApiSvc.updateEventParams(autoTranslate: value);
      await AppUser.inst.refreshUser();
      SmartDialog.dismiss();
    } else {
      pushVip(VipFrom.trans);
    }
  }

  Future<void> changeChatBackground() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final cachedImagePath =
          '${directory.path}${Platform.pathSeparator}${pickedFile.name}';
      final File cachedImage = await File(
        pickedFile.path,
      ).copy(cachedImagePath);
      StorageUtils.chatBgImagePath = cachedImage.path;
      chatBgImagePath.value = cachedImage.path;
      SmartDialog.showNotify(
        msg: LocaleKeys.successful.tr,
        notifyType: NotifyType.success,
      );
    }
  }

  void resetChatBackground() {
    StorageUtils.chatBgImagePath = '';
    chatBgImagePath.value = '';
    SmartDialog.showNotify(
      msg: LocaleKeys.completed.tr,
      notifyType: NotifyType.success,
    );
  }
}
