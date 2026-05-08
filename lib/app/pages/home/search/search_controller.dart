import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/pages/home/home_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

class SearchController extends GetxController {
  //TODO: Implement SearchController

  final count = 0.obs;

  var searchController = TextEditingController();

  var roleContentController = PageLoadRoleController();

  @override
  void onClose() {
    searchController.dispose();
    roleContentController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> onSubmitted(String value) async {
    value = value.trim();
    if (value.isVoid) return;
    SmartDialog.showLoading();
    roleContentController.name = value;
    roleContentController.tagIds = [];
    await roleContentController.onRefresh();
    SmartDialog.dismiss();
  }
}
