import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:medtrac/controllers/appointment_summary_controller.dart';
import 'package:medtrac/controllers/document_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/doctors_advice_widget.dart';
import 'package:medtrac/custom_widgets/document_widget.dart';
import 'package:medtrac/custom_widgets/patients_history_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/custom_widgets/patient_health_status_widget.dart';
import 'package:medtrac/views/pdf_viewer/pdf_viewer_screen.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class AppointmentSummaryScreen extends GetView<AppointmentSummaryController> {
  final DocumentController documentController = Get.find<DocumentController>();
   AppointmentSummaryScreen({super.key});

  // Helper methods to convert API data to proper enums
  MoodType _getMoodFromString(String mood) {
    if (mood.toLowerCase().contains('excellent') || mood.toLowerCase().contains('great') || mood.toLowerCase().contains('amazing') || mood.toLowerCase().contains('good') || mood.toLowerCase().contains('fine') || mood.toLowerCase().contains('well')) {
      return MoodType.good;
    } else if (mood.toLowerCase().contains('moderate') || mood.toLowerCase().contains('neutral') || mood.toLowerCase().contains('okay')) {
      return MoodType.moderate;
    } else if (mood.toLowerCase().contains('poor') || mood.toLowerCase().contains('bad') || mood.toLowerCase().contains('terrible') || mood.toLowerCase().contains('awful')) {
      return MoodType.poor;
    } else {
      return MoodType.moderate; // default
    }
  }

  SleepQuality _getSleepQualityFromString(String sleepQuality) {
    switch (sleepQuality.toLowerCase()) {
      case 'excellent':
        return SleepQuality.excellent;
      case 'good':
        return SleepQuality.good;
      case 'fair':
        return SleepQuality.fair;
      case 'poor':
        return SleepQuality.poor;
      case 'worst':
        return SleepQuality.worst;
      default:
        return SleepQuality.good; // Default fallback
    }
  }

  StressLevel _getStressLevelFromInt(int stressLevel) {
    switch (stressLevel) {
      case 1:
        return StressLevel.veryLow;
      case 2:
        return StressLevel.low;
      case 3:
        return StressLevel.moderate;
      case 4:
        return StressLevel.high;
      case 5:
        return StressLevel.veryHigh;
      default:
        return StressLevel.moderate; // Default fallback
    }
  }

  // Helper method to get file extension
  String _getFileExtension(String url) {
    return url.split('.').last.toLowerCase();
  }

  // Helper method to determine if file is image
  bool _isImageFile(String url) {
    final extension = _getFileExtension(url);
    return ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Helper method to get document name from URL
  String _getDocumentName(String url, String type) {
    try {
      String fileName = url.split('/').last;
      // Remove query parameters if any
      fileName = fileName.split('?').first;
      return fileName.isNotEmpty ? fileName : '$type Document';
    } catch (e) {
      return '$type Document';
    }
  }

  // Dynamic prescription documents widget
  Widget _buildPrescriptionDocuments() {
    final prescriptionUrls = controller.prescriptionDocuments;
    
    if (prescriptionUrls.isEmpty) {
      return DocumentsWidget(
        title: "Prescription", 
        documents: documentController.allPerscriptionDocument,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Prescription",
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          10.verticalSpace,
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: prescriptionUrls.length,
              separatorBuilder: (context, index) => 16.horizontalSpace,
              itemBuilder: (context, index) {
                final url = prescriptionUrls[index];
                final documentName = _getDocumentName(url, 'Prescription');
                
                return GestureDetector(
                  onTap: () {
                    Get.to(() => PdfViewerScreen(
                      pdfUrl: url,
                      title: documentName,
                    ));
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        Assets.pdfIcon,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          documentName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic shared documents widget
  Widget _buildSharedDocuments() {
    final sharedDocUrls = controller.sharedDocumentUrls;
    
    if (sharedDocUrls.isEmpty) {
      return DocumentsWidget(
        title: "Shared Documents", 
        documents: documentController.allSharedDocument,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Shared Documents",
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          10.verticalSpace,
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sharedDocUrls.length,
              separatorBuilder: (context, index) => 16.horizontalSpace,
              itemBuilder: (context, index) {
                final url = sharedDocUrls[index];
                final isImage = _isImageFile(url);
                final documentName = _getDocumentName(url, 'Shared');
                
                return GestureDetector(
                  onTap: () {
                    if (isImage) {
                      // For images, could open in image viewer or PDF viewer
                      Get.to(() => PdfViewerScreen(
                        pdfUrl: url,
                        title: documentName,
                      ));
                    } else {
                      Get.to(() => PdfViewerScreen(
                        pdfUrl: url,
                        title: documentName,
                      ));
                    }
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        isImage ? Assets.pngIcon : Assets.pdfIcon,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          documentName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Summary',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.loadAppointmentDetails(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.verticalSpace,
                _buildDynamicUserInfo(),
                16.verticalSpace,
                DoctorsAdviceWidget(controller: controller),
                16.verticalSpace,
                _buildPrescriptionDocuments(),
                16.verticalSpace,
                PatientsHistoryWidget(
                  medicationTags: controller.dynamicMedicationTags,
                  primaryConcernTags: controller.dynamicPrimaryConcernTags,
                ),
                16.verticalSpace,
                PatientHealthStatusWidget(
                  feeling: _getMoodFromString(controller.mood),
                  sleepQuality: _getSleepQualityFromString(controller.sleepQuality),
                  stressLevel: _getStressLevelFromInt(controller.stressLevel),
                ),
                16.verticalSpace,
                _buildSharedDocuments(),
                16.verticalSpace,
                CustomElevatedButton(
                  text: "Chat",
                  imagePath: Assets.chatIcon,
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.chatScreen,
                      arguments: {
                        'otherUserId': controller.isUser 
                            ? controller.doctorId 
                            : controller.patientId,
                        'otherUserName': controller.displayName,
                        'otherUserProfilePicture': controller.displayImage,
                      },
                    );
                  },
                  isSecondary: true,
                  isOutlined: true,
                ),
                32.verticalSpace,
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDynamicUserInfo() {
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
              image: DecorationImage(
                image: _getImageProvider(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: _getDisplayName(),
                  fontWeight: FontWeight.bold,
                ),
                if (_getSubtitle().isNotEmpty) ...[
                  CustomText(
                    text: _getSubtitle(),
                    fontSize: 12.sp,
                    color: AppColors.darkGreyText,
                  ),
                ],
                if (_getDescription().isNotEmpty) ...[
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  BodyTextTwo(
                    text: _getDescription(),
                    color: AppColors.darkGreyText,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    String image = controller.displayImage;
    if (image.isNotEmpty) {
      return NetworkImage(image);
    }
    
    if (controller.isUser) {
      return const AssetImage('assets/images/doctor_placeholder.png');
    } else {
      return const AssetImage('assets/images/patient_placeholder.png');
    }
  }

  String _getDisplayName() {
    return controller.displayName;
  }

  String _getSubtitle() {
    if (controller.isUser) {
      return "MBBS, M.D"; // Could be enhanced with API data
    } else {
      return ""; // Patients don't have subtitles
    }
  }

  String _getDescription() {
    if (controller.isUser) {
      return controller.displaySpeciality.isNotEmpty 
          ? "${controller.displaySpeciality} - Family Medicine"
          : "Specialist - Family Medicine";
    } else {
      return ""; // Patients don't have descriptions
    }
  }
}
