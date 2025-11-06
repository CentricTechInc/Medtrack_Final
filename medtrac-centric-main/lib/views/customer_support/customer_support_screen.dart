import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/customer_support_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/views/customer_support/widget/explain_problem_input_widget.dart';

class CustomerSupportScreen extends GetView<CustomerSupportController> {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Support",),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BodyTextTwo(text: "Helping you 24/7"),s
                  20.verticalSpace,
                  BodyTextOne(text: "Title"  , fontWeight: FontWeight.w700,),
                  10.verticalSpace,
                  CustomTextFormField(hintText: "Add your issue title here" , controller: controller.titleController, ),
                  20.verticalSpace,
                  BodyTextOne(text: "Explanation" , fontWeight: FontWeight.w700,),
                  10.verticalSpace,
                  ExplainProblemInputWidget(controller: controller.explainProblemController),
                  30.verticalSpace, // spacing at bottom
                  Obx(() => CustomElevatedButton(
                      text: 'Submit',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.onSubmitButtonPressed)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
