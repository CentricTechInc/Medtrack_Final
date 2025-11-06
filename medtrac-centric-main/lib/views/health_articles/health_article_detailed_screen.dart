import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

import 'package:medtrac/controllers/wellness_hub_controller.dart';


class HealthArticleDetailedScreen extends StatefulWidget {
  const HealthArticleDetailedScreen({super.key});

  @override
  State<HealthArticleDetailedScreen> createState() => _HealthArticleDetailedScreenState();
}

class _HealthArticleDetailedScreenState extends State<HealthArticleDetailedScreen> {
  final arguments = Get.arguments ?? {};
  final WellnessHubController _controller = Get.find<WellnessHubController>();

  @override
  void initState() {
    super.initState();
    final int articleId = arguments['id'];
    _controller.fetchArticleDetailsRx(articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Articles"),
      body: Obx(() {
        if (_controller.isArticleDetailLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final data = _controller.articleDetailData;
        if (data == null) {
          return Center(child: Text("Failed to load article details"));
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.lightGrey3,
                    child: const Icon(Icons.person, color: AppColors.bright),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTextTwo(
                        text: "Admin",
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 2),
                      BodyTextTwo(
                        text: data.createdAt,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HeadingTextTwo(
                text: data.title,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                        image: NetworkImage(data.assets),
                        height: 230.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )

              ),
              const SizedBox(height: 16),
              BodyTextTwo(
                text: data.description,
              ),
            ],
          ),
        );
      }),
    );
  }
}
