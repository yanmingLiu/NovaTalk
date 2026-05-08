import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../generated/assets.dart';
import '../../../generated/locales.g.dart';
import '../../entities/role_tags_entity.dart';
import 'home_controller.dart';

const _filterAccent = Color(0xFFFF96F7);
const _filterAccentLight = Color(0xFFFFDFFD);
const _filterPanel = Color(0xFF331E31);

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final ctr = Get.find<RolesController>();

  late final List<RoleTagsEntity> types = ctr.roleTags.length > 2
      ? ctr.roleTags.take(2).toList()
      : ctr.roleTags;
  late RoleTagsEntity selectedType = types.first;
  late final Set<RoleTagsTagList> selectTags = Set<RoleTagsTagList>.from(
    ctr.selectTags,
  );

  @override
  Widget build(BuildContext context) {
    final tags = selectedType.tags;
    final containsAll =
        tags != null && tags.isNotEmpty && selectTags.containsAll(tags);

    return Container(
      height: Get.height,
      color: Colors.black,
      child: Stack(
        children: [
          const _FilterTopGlow(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             kToolbarHeight.verticalSpace,
              _buildHeader(containsAll, tags),
              26.verticalSpace,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FilterTitle(),
                      20.verticalSpace,
                      _buildTypeTabs(),
                      16.verticalSpace,
                      Expanded(child: _buildTags()),
                      16.verticalSpace,
                      _buildConfirmButton(),
                      40.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool containsAll, List<RoleTagsTagList>? tags) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 11.h),
      child: Row(
        children: [
          TapBox(
            onTap: Get.back,
            child: buildCloseIcon(color: Colors.white),
          ),
          const Spacer(),
          TapBox(
            onTap: () {
              if (containsAll) {
                selectTags.removeAll(tags ?? []);
              } else {
                selectTags.addAll(tags ?? []);
              }
              setState(() {});
            },
            child: Container(
              width: 102.w,
              height: 28.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _filterPanel,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child:
                  (containsAll
                          ? LocaleKeys.cancel.tr
                          : LocaleKeys.selectAllItems.tr)
                      .tv(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _filterAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Row(
      children: List.generate(types.length, (index) {
        final type = types[index];
        final isSelected = identical(type, selectedType);
        return Padding(
          padding: EdgeInsets.only(right: index == types.length - 1 ? 0 : 40.w),
          child: TapBox(
            onTap: () {
              selectedType = type;
              setState(() {});
            },
            child: _FilterTypeItem(type: type, selected: isSelected),
          ),
        );
      }),
    );
  }

  Widget _buildTags() {
    final tags = selectedType.tags;
    if (tags == null || tags.isEmpty) {
      return const SizedBox();
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: tags.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 40.h,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
      ),
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = selectTags.contains(tag);
        return TapBox(
          onTap: () {
            if (isSelected) {
              selectTags.remove(tag);
            } else {
              selectTags.add(tag);
            }
            setState(() {});
          },
          child: _FilterTagItem(tag: tag, selected: isSelected),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: TapBox(
        onTap: () {
          Get.dismissBottomSheet();
          ctr.filterEvent.value = Set<RoleTagsTagList>.from(selectTags);
          ctr.filterEvent.refresh();
          ctr.selectTags.assignAll(selectTags);
        },
        child: Container(
          width: 250.w,
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_filterAccentLight, _filterAccent],
            ),
          ),
          child: LocaleKeys.confirmSel.tr.tv(
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTopGlow extends StatelessWidget {
  const _FilterTopGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 300.h,
        width: double.infinity,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.40,
              child: Assets.imagesBgCommon.iv(
                width: Get.width,
                height: 210.h,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 120.h,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0), Colors.black],
                    stops: const [0.05, 0.60],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTitle extends StatelessWidget {
  const _FilterTitle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 2.w,
          bottom: 2.h,
          child: Container(
            width: 218.w,
            height: 12.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              gradient: LinearGradient(
                colors: [_filterAccent, _filterAccent.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        LocaleKeys.pickTags.tr.tv(
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _FilterTypeItem extends StatelessWidget {
  const _FilterTypeItem({required this.type, required this.selected});

  final RoleTagsEntity type;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final title = type.labelType ?? '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (selected)
          Positioned(
            left: 0,
            bottom: 1.h,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                gradient: LinearGradient(
                  colors: [_filterAccent, _filterAccent.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        title.tv(
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.85),
            fontSize: selected ? 16.sp : 14.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FilterTagItem extends StatelessWidget {
  const _FilterTagItem({required this.tag, required this.selected});

  final RoleTagsTagList tag;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: selected
            ? _filterAccent.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: (tag.name ?? '').tv(
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected
              ? _filterAccent
              : Colors.white.withValues(alpha: 0.85),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
