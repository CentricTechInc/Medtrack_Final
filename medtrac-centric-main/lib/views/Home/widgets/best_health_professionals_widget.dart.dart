import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/custom_doctor_tile.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';

class BestHealthProfessionalsWidget extends StatelessWidget {
  final BottomNavigationController _bottomNavBarcontroller =
      Get.find<BottomNavigationController>();
  final HomeController _homeController = Get.find<HomeController>();
      
  BestHealthProfessionalsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: 'Best Health Professionals',
              fontWeight: FontWeight.w700,
            ),
            GestureDetector(
              onTap: () {
                if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                  HelperFunctions.showIncompleteProfileBottomSheet();
                  return;
                }
                _bottomNavBarcontroller.selectedNavIndex.value = 2;
              },
              child: const BodyTextOne(
                text: 'see all',
                fontWeight: FontWeight.w600,
                color: AppColors.lightGreyText,
              ),
            ),
          ],
        ),
        16.verticalSpace,
        Obx(() {
          if (_homeController.isLoadingProfessionals.value) {
            return SizedBox(
              height: 135.h,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_homeController.bestHealthProfessionals.isEmpty) {
            return SizedBox(
              height: 135.h,
              child: const Center(
                child: BodyTextOne(
                  text: 'No health professionals found',
                  color: AppColors.lightGreyText,
                ),
              ),
            );
          }

          return SizedBox(
            height: 135.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _homeController.bestHealthProfessionals.length,
              separatorBuilder: (context, index) => 4.horizontalSpace,
              itemBuilder: (context, index) {
                final doctor = _homeController.bestHealthProfessionals[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 70.w,
                  child: CustomDoctorTile(
                    name: doctor.displayName,
                    age: "0",
                    fee: doctor.regularFees.toString(),
                    isEmergency: doctor.isEmergency,
                    profilePictureURL: doctor.picture ?? "",
                    rating: doctor.averageRating,
                    specialty: doctor.speciality ?? "",
                    onTap: () {
                      _homeController.onProfessionalTap(doctor);
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
