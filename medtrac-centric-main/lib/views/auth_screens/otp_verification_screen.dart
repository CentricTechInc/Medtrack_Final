import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/login_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final LoginController controller = Get.put(LoginController());
  late final Map<String, dynamic> arguments;
  late final String email;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments as Map<String, dynamic>? ?? {};
    email = arguments['email'] as String? ?? "";
    controller.initialise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top -
                48.w, // padding
          ),
          child: IntrinsicHeight(
            child: AbsorbPointer(
              absorbing: controller.isLoading.value,
              child: Column(
                children: [
                  HeadingTextOne(
                    text: "Verify Your Email Address",
                    textAlign: TextAlign.center,
                    color: AppColors.secondary,
                  ),
                  16.verticalSpace,
                  HeadingTextTwo(
                    text:
                        "Enter the OTP sent to your email to\nreset your password.",
                    textAlign: TextAlign.center,
                    color: AppColors.darkGreyText,
                    fontSize: 16.sp,
                  ),
                  60.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: 50.w,
                        height: 65.w,
                        child: TextField(
                          controller: controller.otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  BorderSide(color: AppColors.lightGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 3) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                            controller.updateOtpValue();
                          },
                        ),
                      ),
                    ),
                  ),
                  24.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyTextOne(
                        text: "Didn't receive the OTP? ",
                        color: AppColors.darkGreyText,
                      ),
                      TextButton(
                        onPressed: controller.resendOtp,
                        child: HeadingTextTwo(
                          text: "Resend.",
                          color: AppColors.primary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Obx(() {
                    return CustomElevatedButton(
                      text: 'Verify',
                      onPressed: () => controller.verifyOtp(
                          emailPassed: email,
                          fromRegistration:
                              (arguments['fromRegistration'] as bool?) ?? controller.fromRegistration ?? false),
                      isLoading: controller.isLoading.value,
                    );
                  }),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
