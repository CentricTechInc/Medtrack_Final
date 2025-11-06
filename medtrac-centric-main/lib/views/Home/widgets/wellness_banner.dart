import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/controllers/home_controller.dart';

class WellnessBanner extends GetView<HomeController> {
  const WellnessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state if banners are being loaded
      if (controller.isLoadingBanners.value) {
        return SizedBox(
          height: 172.h,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      // If no banners available, show fallback
      if (controller.banners.isEmpty) {
        return SizedBox(
          height: 172.h,
          child: _buildFallbackBanner(),
        );
      }

      return SizedBox(
        height: 172.h,
        child: _BannerSlider(banners: controller.banners),
      );
    });
  }

  Widget _buildFallbackBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 172.h,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/wellness_bg.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        Container(
          width: double.infinity,
          height: 172.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0E121D).withValues(alpha: 0.50),
                const Color(0xFF4D5765).withValues(alpha: 0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        Positioned(
          top: 31.h,
          left: 30.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wellness for Lifelong Growth',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25.h,
                ),
              ),
              16.verticalSpace,
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Now',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerSlider extends StatefulWidget {
  final RxList banners;

  const _BannerSlider({required this.banners});

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = widget.banners;
      
      if (banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return _buildBannerSlide(banners[index]);
            },
          ),
          if (banners.length > 1)
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (index) {
                  return Container(
                    width: 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildBannerSlide(dynamic banner) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 172.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(banner.file),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Fallback to default image on network error
              },
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: banner.file.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/wellness_bg.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                )
              : null,
        ),
        Container(
          width: double.infinity,
          height: 172.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0E121D).withValues(alpha: 0.50),
                const Color(0xFF4D5765).withValues(alpha: 0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        Positioned(
          top: 31.h,
          left: 30.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25.h,
                ),
              ),
              16.verticalSpace,
              ElevatedButton(
                onPressed: () {
                  // Add banner action here if needed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
