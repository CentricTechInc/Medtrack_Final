import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/cached_video_thumbnail.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';

class WellnessHubSection extends StatelessWidget {
  final WellnessHubController controller = Get.find<WellnessHubController>();

  WellnessHubSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: 'Wellness Hub',
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
                  controller.currentTabIndex.value = 1;
                  Get.toNamed(AppRoutes.wellnessHubScreen);
                }
              },
            ),
          ],
        ),
        8.verticalSpace,
        SizedBox(
          height: 192.h,
          child: Obx(() {
            if (controller.isLoadingVideos.value &&
                controller.wellnessVideos.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (controller.wellnessVideos.isEmpty) {
              return Center(
                child: Text(
                  'No videos available',
                  style: TextStyle(
                    color: AppColors.lightGreyText,
                    fontSize: 14.sp,
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.wellnessVideos.length,
              itemBuilder: (context, index) {
                final video = controller.wellnessVideos[index];
                return GestureDetector(
                  onTap: () {
                    if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                      HelperFunctions.showIncompleteProfileBottomSheet();
                    } else {
                      controller.onVideoTapped(video);
                    }
                  },
                  child: Container(
                    width: 185.w,
                    height: 192.h,
                    margin: EdgeInsets.only(
                        right: index < controller.wellnessVideos.length - 1
                            ? 16.w
                            : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background image/thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: video.type == 'Video' &&
                                  video.assets.endsWith('.mp4')
                              ? CachedVideoThumbnail(
                                  videoUrl: video.assets,
                                  width: 185.w,
                                  height: 192.h,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(16.r),
                                  placeholder: Container(
                                    width: 185.w,
                                    height: 192.h,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF357ABD)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.bright,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget:
                                      _buildFallbackImage(video.assets),
                                )
                              : _buildFallbackImage(video.assets),
                        ),
                        // Dark overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        // Play button
                        Center(
                          child: Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: AppColors.dark.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 32.r,
                            ),
                          ),
                        ),
                        // Title at bottom
                        Positioned(
                          bottom: 12.h,
                          left: 12.w,
                          right: 12.w,
                          child: Text(
                            video.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFallbackImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 185.w,
        height: 192.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 185.w,
            height: 192.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 185.w,
            height: 192.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.bright,
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 185.w,
        height: 192.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
  }
}
