import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/document_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/models/document_model.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/pdf_viewer/pdf_viewer_screen.dart';

class DocumentsWidget extends StatelessWidget {
  final List<Document> documents;
  final String title;
  final DocumentController documentController = Get.find<DocumentController>();

  DocumentsWidget({
    super.key,
    required this.documents,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
            text: title,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          10.verticalSpace,
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: documents.length,
              separatorBuilder: (context, index) => 16.horizontalSpace,
              itemBuilder: (context, index) {
                final Document document = documents[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => PdfViewerScreen(
                          pdfUrl: Assets.dummyFilePath,
                          title: document.name,
                        ));
                    debugPrint('Tapped on: ${document.name}');
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
                      Text(
                        document.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
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
}
