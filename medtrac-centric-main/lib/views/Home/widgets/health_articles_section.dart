import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class HealthArticlesSection extends StatelessWidget {
  final WellnessHubController controller = Get.find<WellnessHubController>();

  HealthArticlesSection({super.key,});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: 'Health Articles',
              fontWeight: FontWeight.w700,
            ),
            GestureDetector(
              child: const BodyTextOne(
                text: 'see all',
                fontWeight: FontWeight.w600,
                color: AppColors.lightGreyText,
              ),
              onTap: () {
                if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                  HelperFunctions.showIncompleteProfileBottomSheet();
                } else {
                  Get.toNamed(AppRoutes.wellnessHubScreen);
                   controller.currentTabIndex.value = 0;
                }
              },
            ),
          ],
        ),
        8.verticalSpace,
        SizedBox(
          height: 221.h,
          child: Obx(
            () {
              if (controller.isLoadingArticles.value &&
                  controller.wellnessArticles.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (controller.wellnessArticles.isEmpty) {
                return Center(
                  child: Text(
                    'No articles available',
                    style: TextStyle(
                      color: AppColors.lightGreyText,
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.wellnessArticles.length,
                itemBuilder: (context, index) {
                  final article = controller.wellnessArticles[index];
                  return GestureDetector(
                    onTap: () {
                      if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                        HelperFunctions.showIncompleteProfileBottomSheet();
                      } else {
                        // Navigate directly to article details with HealthArticle data
                        Get.toNamed(AppRoutes.healthArticcleDetailedScreen,
                            arguments: {
                              'id': article.id,
                            });
                      }
                    },
                    child: Container(
                      width: 221.w,
                      margin: EdgeInsets.only(
                          right: index < controller.wellnessArticles.length - 1
                              ? 16.w
                              : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 116.h,
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.r),
                                  topRight: Radius.circular(8.r),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(article.assets),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                8.verticalSpace,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildBadge(
                                        Assets.calanderIcon, article.createdAt),
                                    _buildBadge(
                                        Assets.bookIcon, article.duration),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String iconPath, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 16.w,
            height: 16.h,
          ),
          SizedBox(width: 4.w),
          BodyTextTwo(
            text: text,
          )
        ],
      ),
    );
  }
}
