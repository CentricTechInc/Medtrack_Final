import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/wellness_hub/wellness_content_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WellnessHubScreen extends StatelessWidget {
  final WellnessHubController _controller = Get.find<WellnessHubController>();

  WellnessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Wellness Hub"),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: CustomTextFormField(
              hintText: "Search",
              prefixIcon: Icons.search,
              hasBorder: false,
              fillColor: AppColors.lightGrey,
              controller: _controller.searchController,
              onChanged: _controller.onSearchChanged,
              suffixIcon: GetBuilder<WellnessHubController>(
                builder: (controller) {
                  return controller.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.onSearchChanged('');
                          },
                        )
                      : SizedBox.shrink();
                },
              ),
            ),
          ),
          10.verticalSpace,
          Obx(
            () {
              final _ = _controller.currentTabIndex.value;
              return CustomTabBar(
                tabs: ["Articles", "Videos"],
                currentIndex: _controller.currentTabIndex,
                onTabChanged: (currentTab) =>
                    _controller.onTabChanged(currentTab),
              );
            },
          ),
          20.verticalSpace,
          Expanded(
            child: Obx(() {
              final isArticlesTab = _controller.currentTabIndex.value == 0;
              final list = _controller.currentList;
              final isLoading = _controller.isLoading;
              final refreshController = _controller.currentRefreshController;

              if (isLoading && list.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (!isLoading && list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isArticlesTab
                            ? Icons.article_outlined
                            : Icons.video_library_outlined,
                        size: 64.sp,
                        color: AppColors.lightGreyText,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _controller.searchController.text.isNotEmpty
                            ? 'No results found for "${_controller.searchController.text}"'
                            : 'No ${isArticlesTab ? "articles" : "videos"} available',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.lightGreyText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return SmartRefresher(
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: _controller.onRefresh,
                onLoading: _controller.onLoading,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("Pull up to load more");
                    } else if (mode == LoadStatus.loading) {
                      body = CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      );
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed! Click retry!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("Release to load more");
                    } else {
                      body = Text("No more data");
                    }
                    return SizedBox(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return GestureDetector(
                      onTap: () {
                        if (isArticlesTab) {
                          Get.toNamed(
                            AppRoutes.healthArticcleDetailedScreen,
                            arguments: {
                              "id": item.id,
                            },
                          );
                        } else {
                          _controller.onVideoTapped(item);
                        }
                      },
                      child: WellnessContentCard(
                        imageUrl: item.assets,
                        title: item.title,
                        date: item.createdAt,
                        duration: item.duration,
                        isVideo: item.type == 'Video',
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
