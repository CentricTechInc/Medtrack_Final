import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/cancel_booking_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/dynamic_doctor_info_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class CancelBookingScreen extends GetView<CancelBookingController> {
   const CancelBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cancel Appointment',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dynamic doctor info
              HelperFunctions.isUser() ? 
              DynamicDoctorInfoWidget(
                doctorName: controller.doctorName,
                doctorImage: controller.doctorImage,
                doctorQualifications: controller.doctorQualifications,
                doctorSpeciality: controller.doctorSpeciality,
              ) : PatientInfoWidget(
                name: controller.doctorName,
                image: controller.doctorImage,
              ) ,
              54.verticalSpace,
              
              // Radio buttons for cancellation reasons
              Obx(() => ListView.builder(
                itemCount: controller.cancelReasons.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: BodyTextOne(
                      text: controller.cancelReasons[index],
                      fontWeight: FontWeight.w700,
                    ),
                    leading: InkWell(
                      onTap: () {
                        controller.selectedReason.value = controller.cancelReasons[index];
                      },
                      child: Obx(() {
                        bool isSelected = controller.selectedReason.value == controller.cancelReasons[index];
                        return Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                ? AppColors.primary
                                : AppColors.secondary,
                              width: isSelected ? 6.0 : 1.0,
                            ),
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  );
                },
              )),
              
              16.verticalSpace,
              
              // Text field for additional reason
              CustomTextFormField(
                controller: controller.reasonTextController,
                hintText: 'Enter Your Reason',
                maxLines: 5,
                fillColor: AppColors.bright,
              ),
              
              SizedBox(height: 60.h),
              
              // Cancel button with loading state
              Obx(() => CustomElevatedButton(
                text: controller.isLoading.value ? 'Cancelling...' : 'Cancel Appointment',
                onPressed: !controller.isLoading.value 
                  ? () => controller.showCancelConfirmation()
                  : () {}, // Empty function when loading
              )),
              32.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class PatientInfoWidget extends StatelessWidget {
  final String name;
  final String image;

  const PatientInfoWidget({
    super.key, required this.name, required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: image.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(Assets.vermaImage2),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: HeadingTextTwo(
              text: name,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

