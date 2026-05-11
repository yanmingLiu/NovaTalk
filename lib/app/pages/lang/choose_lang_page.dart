import 'package:novatalk/app/configs/app_config.dart';
import 'package:novatalk/app/utils/api_svc.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/common_utils.dart';
import 'package:novatalk/app/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../configs/app_theme.dart';
import '../../entities/lang.dart';
import 'a_z_list_cursor.dart';
import 'a_z_list_index_bar.dart';
import 'a_z_list_item_view.dart';
import 'a_z_list_model.dart';

class ChooseLangPage extends StatefulWidget {
  const ChooseLangPage({super.key});

  @override
  State<ChooseLangPage> createState() => _ChooseLangPageState();
}

class _ChooseLangPageState extends State<ChooseLangPage> {
  static const _accent = Color(0xFFFF96F7);
  static const _accentLight = Color(0xFFFFDFFD);

  List<AzListContactModel> contactList = [];

  List<String> get symbols => contactList.map((e) => e.section).toList();

  final indexBarContainerKey = GlobalKey();

  bool isShowListMode = true;

  ValueNotifier<AzListCursorInfoModel?> cursorInfo = ValueNotifier(null);

  double indexBarWidth = 24;

  ScrollController scrollController = ScrollController();

  late SliverObserverController observerController;

  final Map<int, GlobalKey> sliverKeyMap = {};

  var choosedName = ''.obs;
  Lang? selectedLang; // 保存选中的语言对象

  final loader = Loader();

  // 注释掉原有的 generateContactData 方法
  // void generateContactData() {
  //   final a = const Utf8Codec().encode("A").first;
  //   final z = const Utf8Codec().encode("Z").first;
  //   int pointer = a;
  //   while (pointer >= a && pointer <= z) {
  //     final character = const Utf8Codec().decode(Uint8List.fromList([pointer]));
  //     contactList.add(
  //       AzListContactModel(
  //         section: character,
  //         names: List.generate(Random().nextInt(8), (index) {
  //           return '$character-$index';
  //         }),
  //       ),
  //     );
  //     pointer++;
  //   }
  // }

  // 新的 generateContactData 方法，使用 loadAppLangs 获取数据
  Future<void> generateContactData() async {
    try {
      loader.loading();
      sliverKeyMap.clear();
      if (mounted) {
        setState(() {});
      }
      SmartDialog.showLoading();
      final appLangs = await AppConfig.supportLang.future.timeout(10.seconds);
      SmartDialog.dismiss();

      _buildContactListFromData(appLangs);
      loader.success();
    } catch (e) {
      loader.error();
    }
  }

  // 从数据构建联系人列表的辅助方法
  void _buildContactListFromData(Map<String, dynamic> appLangs) {
    contactList.clear();

    // 遍历每个字母分组
    appLangs.forEach((key, value) {
      if (value is List) {
        List<String> names = [];
        List<Lang> langs = [];

        // 将每个语言项转换为 Lang 对象
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            final lang = Lang.fromJson(item);
            if (lang.label != null) {
              names.add(lang.label!);
              langs.add(lang);
            }
          }
        }

        if (names.isNotEmpty) {
          contactList.add(
            AzListContactModel(section: key, names: names, langList: langs),
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    observerController = SliverObserverController(controller: scrollController);

    _loadLanguageData();
  }

  @override
  void dispose() {
    cursorInfo.dispose();
    scrollController.dispose();
    loader.close();
    super.dispose();
  }

  Future<void> _loadLanguageData() async {
    await generateContactData();

    // 设置默认选中的语言
    _setDefaultSelectedLanguage();

    if (mounted) {
      setState(() {});
    }
  }

  /// 设置默认选中的语言
  Future<void> _setDefaultSelectedLanguage() async {
    try {
      // 使用 UserHelper 的 matchUserLang 方法获取匹配的语言
      final matchedLang = await AppUser.inst.matchUserLang();

      if (matchedLang.label != null) {
        choosedName.value = matchedLang.label!;
        selectedLang = matchedLang;
      }
    } catch (e) {
      goPrint('language error: $e');
    }
  }

  /// 保存按钮点击处理
  void _onSaveButtonTapped() async {
    if (selectedLang != null) {
      SmartDialog.showLoading();

      final isOK = await ApiSvc.updateEventParams(lang: selectedLang?.value);
      if (isOK) {
        AppUser.inst.targetLanguage.value = selectedLang!;
        AppUser.inst.refreshUser();
      }

      SmartDialog.dismiss();

      // 返回上一页
      Get.back(result: selectedLang);
    } else {
      // 可以显示提示信息
      SmartDialog.showToast(LocaleKeys.chooseLang.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildNavBar(),
              7.verticalSpace,
              _buildLanguageCard(),
              if (!loader.isSuccess)
                const Expanded(child: SizedBox.shrink())
              else
                Expanded(
                  child: Stack(
                    children: [
                      SliverViewObserver(
                        controller: observerController,
                        sliverContexts: () {
                          return sliverKeyMap.values
                              .map((key) => key.currentContext)
                              .nonNulls
                              .toList();
                        },
                        child: CustomScrollView(
                          key: ValueKey(isShowListMode),
                          controller: scrollController,
                          slivers: [
                            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                            ...contactList.indexed.map((item) {
                              return _buildSliver(
                                index: item.$1,
                                model: item.$2,
                              );
                            }),
                            SliverToBoxAdapter(child: SizedBox(height: 160.h)),
                          ],
                        ),
                      ),
                      _buildCursor(),
                      Positioned(
                        top: 16.h,
                        bottom: 0,
                        right: 0,
                        child: _buildIndexBar(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildSaveButton(),
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

  Widget _buildNavBar() {
    return SizedBox(
      height: 44.h,
      width: Get.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16.w,
            top: 11.h,
            child: TapBox(
              onTap: () {
                Get.back();
              },
              child: buildBackIcon(),
            ),
          ),
          LocaleKeys.languageHits.tv(
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return SizedBox(
      width: 343.w,
      height: 75.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              Assets.imagesBgLangHintCard,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 15.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text.rich(
                    TextSpan(
                      children: buildTextSpans(
                        origin: LocaleKeys.langAI.tr,
                        targets: const ["@s"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        buildTargetTextSpan:
                            (String target, TextStyle? style, int index) {
                              return TextSpan(
                                text:
                                    AppUser.inst.targetLanguage.value.label ??
                                    'English',
                                style: style?.copyWith(
                                  color: _accent,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.verticalSpace,
                LocaleKeys.saveConfirm.tv(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom + 38.h),
      child: Center(
        child: TapBox(
          onTap: _onSaveButtonTapped,
          child: Container(
            width: 250.w,
            height: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accentLight, _accent],
              ),
            ),
            child: LocaleKeys.save.tv(
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return ValueListenableBuilder<AzListCursorInfoModel?>(
      valueListenable: cursorInfo,
      builder:
          (BuildContext context, AzListCursorInfoModel? value, Widget? child) {
            Widget resultWidget = Container();
            double top = 0;
            double right = indexBarWidth + 8;
            if (value == null) {
              resultWidget = const SizedBox.shrink();
            } else {
              double titleSize = 80;
              top = value.offset.dy - titleSize * 0.5;
              resultWidget = AzListCursor(size: titleSize, title: value.title);
            }
            resultWidget = Positioned(
              top: top,
              right: right,
              child: resultWidget,
            );
            return resultWidget;
          },
    );
  }

  Widget _buildIndexBar() {
    return Container(
      key: indexBarContainerKey,
      width: indexBarWidth,
      alignment: Alignment.center,
      child: AzListIndexBar(
        parentKey: indexBarContainerKey,
        symbols: symbols,
        onSelectionUpdate: (index, cursorOffset) {
          cursorInfo.value = AzListCursorInfoModel(
            title: symbols[index],
            offset: cursorOffset,
          );
          final sliverContext = sliverKeyMap[index]?.currentContext;
          if (sliverContext == null) return;
          observerController.jumpTo(
            index: 0,
            sliverContext: sliverContext,
            isFixedHeight: true,
            renderSliverType: ObserverRenderSliverType.list,
          );
        },
        onSelectionEnd: () {
          cursorInfo.value = null;
        },
      ),
    );
  }

  Widget _buildSliver({required int index, required AzListContactModel model}) {
    final names = model.names;
    if (names.isEmpty) return const SliverToBoxAdapter();
    final sliverKey = sliverKeyMap.putIfAbsent(index, GlobalKey.new);
    Widget resultWidget = SliverFixedExtentList.builder(
      key: sliverKey,
      itemExtent: 40.h,
      itemBuilder: (context, itemIndex) {
        return Obx(
          () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AzListItemView(
              name: names[itemIndex],
              isChoosed: names[itemIndex] == choosedName.value,
              onTap: () {
                choosedName.value = names[itemIndex];
                // 保存选中的语言对象
                if (model.langList != null &&
                    itemIndex < model.langList!.length) {
                  selectedLang = model.langList![itemIndex];
                }
              },
            ),
          ),
        );
      },
      itemCount: names.length,
    );
    resultWidget = SliverStickyHeader(
      header: Container(
        height: 27.h,
        color: Colors.black,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(
          model.section,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.50),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      sliver: resultWidget,
    );
    return resultWidget;
  }
}
