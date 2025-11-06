import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/add_notes_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class AddNotesScreen extends GetView<AddNotesController> {
  const AddNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Notes',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    44.verticalSpace,
                    // User Profile Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        Assets.vermaImage,
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    16.verticalSpace,
                    // Patient Name Heading
                    HeadingTextTwo(text: "Give Advice to Arjun Sharma"),
                    104.verticalSpace,
                    // Notes TextField
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.bright,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: CustomTextFormField(
                          hintText: "Write Notes...",
                          controller: controller.notesController,
                          maxLines: 5,
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Submit Button
            Obx(() => CustomElevatedButton(
                  text: controller.isSubmitting.value
                      ? "Submitting..."
                      : "Submit",
                  onPressed: controller.isSubmitting.value
                      ? () {}
                      : controller.submitNotes,
                )),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
