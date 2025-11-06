import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final RxInt currentIndex;
  final Function(int) onTabChanged;
  final Color? backgroundColor;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double? height;
  final double? borderRadius;
  final bool showDivider;
  final double? containerPadding;
  final TabController? controller;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    this.backgroundColor,
    this.selectedTabColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.height,
    this.borderRadius,
    this.showDivider = true,
    this.containerPadding,
    this.controller,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> with TickerProviderStateMixin {
  late TabController _tabController;
  Worker? _indexWorker;

  @override
  void initState() {
    super.initState();
    _tabController = widget.controller ?? 
      TabController(length: widget.tabs.length, vsync: this);
    
    if (widget.controller == null) {
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          widget.currentIndex.value = _tabController.index;
          widget.onTabChanged(_tabController.index);
        }
      });
    }

    // Sync the initial tab index with the controller
    if (widget.currentIndex.value != _tabController.index) {
      _tabController.animateTo(
        widget.currentIndex.value,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
    
    // Listen to external index changes
    _indexWorker = ever(widget.currentIndex, (index) {
      if (mounted && !_tabController.indexIsChanging && _tabController.index != index) {
        _tabController.animateTo(
          index,
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      }
    });
  }

  @override
  void dispose() {
    _indexWorker?.dispose();
    if (widget.controller == null) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
@override
Widget build(BuildContext context) {
return Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.w), // slight separation from screen edge
  child: SizedBox(
    width: double.infinity, // stretch to full width
    child: Container(
      height: widget.height ?? 48.h,
      padding: EdgeInsets.symmetric(
        vertical: 6.r,
        horizontal: widget.containerPadding ?? 12.w,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.lightGrey,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / widget.tabs.length;

          return TabBar(
            isScrollable: false, // Force equal width tabs
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: widget.selectedTabColor ?? AppColors.secondary,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
            ),
            splashBorderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelColor: widget.selectedTextColor ?? AppColors.bright,
            unselectedLabelColor: widget.unselectedTextColor ?? Colors.grey,
            dividerHeight: widget.showDivider ? 20 : 0,
            tabs: widget.tabs.map((tab) {
              return SizedBox(
                width: tabWidth, // Equal width per tab
                child: Center(child: Text(tab)),
              );
            }).toList(),
          );
        },
      ),
    ),
  ),
);

}

}
