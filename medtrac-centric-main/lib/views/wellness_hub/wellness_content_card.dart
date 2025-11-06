import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'dart:io';

class WellnessContentCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String duration;
  final bool isVideo;

  final WellnessHubController wellnessHubController = Get.find<WellnessHubController>();
  
  WellnessContentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.duration,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGreyText,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.blue50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Stack(
              children: [
                // Image/Thumbnail
                isVideo && imageUrl.endsWith('.mp4')
                    ? Obx(() {
                        // Check if we have a cached thumbnail
                        final cachedThumbnail =
                            wellnessHubController.getCachedThumbnail(imageUrl);
                        final isGenerating = wellnessHubController
                            .isGeneratingThumbnail(imageUrl);

                        if (cachedThumbnail != null) {
                          return Image.file(
                            File(cachedThumbnail),
                            width: double.infinity,
                            height: 210.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildNetworkImage();
                            },
                          );
                        } else if (isGenerating) {
                          return Container(
                            width: double.infinity,
                            height: 210.h,
                            color: AppColors.lightGrey,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        } else {
                          // Start generating thumbnail
                          wellnessHubController.generateThumbnail(imageUrl);
                          return _buildNetworkImage();
                        }
                      })
                    : _buildNetworkImage(),

                // Video play icon overlay
                if (isVideo)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: AppColors.bright.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            size: 32.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: AppColors.dark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16.r, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColors.dark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isVideo
                                ? Icons.play_circle_outline
                                : Icons.menu_book,
                            size: 16.r,
                            color: AppColors.lightGreyText,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            duration,
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColors.dark),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz,
                        color: AppColors.greyBackgroundColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage() {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 210.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 210.h,
            color: AppColors.lightGrey,
            child: Icon(
              Icons.image_not_supported,
              size: 48.sp,
              color: AppColors.lightGreyText,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 210.h,
            color: AppColors.lightGrey,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    } else {
      // Fallback for non-network images
      return Container(
        width: double.infinity,
        height: 210.h,
        color: AppColors.lightGrey,
        child: Icon(
          Icons.image,
          size: 48.sp,
          color: AppColors.lightGreyText,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
