import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget{
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: CustomAppBar(title: "Privacy Policy",),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(text: "Last Update: 02/04/2025" , fontWeight: FontWeight.w700),
                      10.verticalSpace,
                      BodyTextOne(text: aboutUsContent , fontWeight: FontWeight.normal,),
                      HeadingTextTwo(text: "Privacy Policy",),
                      10.verticalSpace,

                      BodyTextOne(text: "1. Information We Collect" , fontWeight: FontWeight.w700,),
                      10.verticalSpace,
                      
                      BodyTextOne(text: aboutUsContent , fontWeight: FontWeight.normal,),
                      BodyTextOne(text: "2. How We Use Your Information" , fontWeight: FontWeight.w700,),
                      10.verticalSpace,

                      BodyTextOne(text: aboutUsContent , fontWeight: FontWeight.normal,),
                      BodyTextOne(text: "3. How We Protect Your Information" , fontWeight: FontWeight.w700,),
                      10.verticalSpace,

                      BodyTextOne(text: aboutUsContent , fontWeight: FontWeight.normal,),
                      BodyTextOne(text: "4. Sharing Your Information" , fontWeight: FontWeight.w700,),
                      10.verticalSpace,

                      BodyTextOne(text: aboutUsContent , fontWeight: FontWeight.normal,),



                    ],
                  ),
                  // child: Text(privacyPolicyContent ,style: TextStyle(color: AppColors.dark),),
                ),
              ),
            )
          ],
        ),
    );
  }
}