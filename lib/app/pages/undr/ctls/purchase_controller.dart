import 'package:novatalk/app/entities/sku.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/log/log_event.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:get/get.dart';

import '../../../configs/constans.dart';

import '../../../utils/purchase_helper.dart';

class PurchaseArgs {
  final bool isPayPhotoNum;

  PurchaseArgs({required this.isPayPhotoNum});
}

class PurchaseController extends GetxController {
  late final args = Get.arguments as PurchaseArgs;
  final purchases = <Sku>[].obs;
  final selectedPurchase = Sku().obs;

  @override
  void onInit() {
    super.onInit();
    getPurchases();
  }

  @override
  void onReady() {
    super.onReady();
    logEvent(args.isPayPhotoNum ? "t_buyphotos" : "t_buyvideos");
  }

  void getPurchases() async {
    final list = [...PurchaseHelper.inst.coinsSkus];
    list.removeWhere(
      (v) => args.isPayPhotoNum ? v.createImg == null : v.createVideo == null,
    );
    purchases.value = list;
  }

  String getPower(Sku sku) {
    return "${args.isPayPhotoNum ? sku.createImg : sku.createVideo}";
  }

  String get getPayType => args.isPayPhotoNum ? "Photo" : "Video";

  String getUnitPrice(Sku sku) {
    if (sku.productDetails == null) return "";
    var num = (args.isPayPhotoNum ? sku.createImg : sku.createVideo) ?? 0;
    var price = (sku.productDetails!.rawPrice / num).toStringAsFixed(2);
    return "${(sku.productDetails?.currencySymbol).val}$price/${args.isPayPhotoNum ? "Photo" : "Video"}";
  }

  void buy(Sku value) {
    if (value.productDetails == null) return;
    PurchaseHelper.inst.buy(
      value,
      consFrom: args.isPayPhotoNum ? ConsumeFrom.undr : ConsumeFrom.img2v,
      onCompletePurchase: () {
        AppUser.inst.refreshUser();
        Get.back();
      },
    );
  }
}
