import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointment_details_screen_controller.dart';
import 'package:medtrac/controllers/document_controller.dart';
import 'package:medtrac/custom_widgets/patients_history_widget.dart';
import 'package:medtrac/custom_widgets/view_shared_document.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/custom_widgets/patient_health_status_widget.dart';
import 'package:medtrac/views/pdf_viewer/pdf_viewer_screen.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/models/document_model.dart';
import 'package:medtrac/utils/assets.dart';

class PatientHistoryTabViewWidget extends StatelessWidget {
  PatientHistoryTabViewWidget({
    super.key,
    required this.controller,
  });

  final AppointmentDetailsController controller;
  final DocumentController documentController = Get.find<DocumentController>();

  // Helper methods to convert API data to proper enums
  MoodType _getMoodFromString(String mood) {
    if (mood.toLowerCase().contains('excellent') ||
        mood.toLowerCase().contains('great') ||
        mood.toLowerCase().contains('amazing') ||
        mood.toLowerCase().contains('good') ||
        mood.toLowerCase().contains('fine') ||
        mood.toLowerCase().contains('well')) {
      return MoodType.good;
    } else if (mood.toLowerCase().contains('moderate') ||
        mood.toLowerCase().contains('neutral') ||
        mood.toLowerCase().contains('okay')) {
      return MoodType.moderate;
    } else if (mood.toLowerCase().contains('poor') ||
        mood.toLowerCase().contains('bad') ||
        mood.toLowerCase().contains('terrible') ||
        mood.toLowerCase().contains('awful')) {
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

  // Original documents widget design with network URL support and full width for single document
  Widget _buildNetworkDocumentWidget() {
    // Create a list of documents - either from API or fallback to default
    List<Document> documents;

    if (controller.sharedDocuments.isNotEmpty) {
      // Create a document from the network URL
      documents = [
        Document(
          id: "1",
          name: "Shared Document",
          createdAt: DateTime.now(),
          type: "pdf",
          isShared: true,
        )
      ];
    } else {
      // Use default documents
      documents = documentController.allSharedDocument;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: SharedDocumentWidget(fileUrl: controller.sharedDocuments),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     CustomText(
      //       text: "Shared Documents",
      //       fontSize: 20.sp,
      //       fontWeight: FontWeight.w700,
      //       color: AppColors.secondary,
      //     ),
      //     10.verticalSpace,
      //     SizedBox(
      //       height: 100.h,
      //       width: double.infinity, // Take full width
      //       child: documents.length == 1
      //           ? // Single document - center it and make it full width
      //           Center(
      //               child: _buildDocumentItem(documents[0], true),
      //             )
      //           : // Multiple documents - horizontal scroll
      //           ListView.separated(
      //               scrollDirection: Axis.horizontal,
      //               itemCount: documents.length,
      //               separatorBuilder: (context, index) => 16.horizontalSpace,
      //               itemBuilder: (context, index) {
      //                 return _buildDocumentItem(documents[index], false);
      //               },
      //             ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildDocumentItem(Document document, bool isFullWidth) {
    return GestureDetector(
      onTap: () {
        String pdfUrl;
        if (controller.sharedDocuments.isNotEmpty) {
          // Use network URL
          pdfUrl = controller.sharedDocuments;
        } else {
          // Use asset path
          pdfUrl = Assets.dummyFilePath;
        }

        Get.to(() => PdfViewerScreen(
              pdfUrl: pdfUrl,
              title: document.name,
            ));
        debugPrint('Tapped on: ${document.name}');
      },
      child: Container(
        width: isFullWidth ? double.infinity : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.pdfIcon,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 6.h),
            Text(
              document.name,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.verticalSpace,
            PatientsHistoryWidget(
              medicationTags: controller.medication.isNotEmpty
                  ? controller.medication
                  : controller.medicationTags,
              primaryConcernTags: controller.primaryConcern.isNotEmpty
                  ? controller.primaryConcern
                  : controller.primaryConcernTags,
              patientHistory: controller.patientHistory,
            ),
            16.verticalSpace,
            PatientHealthStatusWidget(
              feeling: _getMoodFromString(controller.mood),
              sleepQuality: _getSleepQualityFromString(controller.sleepQuality),
              stressLevel: _getStressLevelFromInt(controller.stressLevel),
            ),
            16.verticalSpace,
            _buildNetworkDocumentWidget(),
          ],
        ),
      ),
    );
  }
}
