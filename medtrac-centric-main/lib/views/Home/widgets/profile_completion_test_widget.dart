// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:medtrac/controllers/home_controller.dart';
// import 'package:medtrac/utils/app_colors.dart';
//  

// class ProfileCompletionTestWidget extends StatelessWidget {
//   const ProfileCompletionTestWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final homeController = Get.find<HomeController>();
    
//     return Container(
//       margin: EdgeInsets.all(16.r),
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: AppColors.bright,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: AppColors.primary, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "🧪 Profile Completion Testing",
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//           16.verticalSpace,
          
//           // Current Status
//           Obx(() => Container(
//             padding: EdgeInsets.all(12.r),
//             decoration: BoxDecoration(
//               color: homeController.isProfileComplete.value 
//                   ? Colors.green.withValues(alpha:0.1) 
//                   : Colors.red.withValues(alpha:0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   homeController.isProfileComplete.value 
//                       ? Icons.check_circle 
//                       : Icons.cancel,
//                   color: homeController.isProfileComplete.value 
//                       ? Colors.green 
//                       : Colors.red,
//                 ),
//                 8.horizontalSpace,
//                 Text(
//                   "Profile Complete: ${homeController.isProfileComplete.value}",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: homeController.isProfileComplete.value 
//                         ? Colors.green 
//                         : Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           )),
          
//           16.verticalSpace,
          
//           // SharedPrefs Status
//           FutureBuilder<bool>(
//             future: Future.value( SharedPrefsServiceisProfileComplete()),
//             builder: (context, snapshot) {
//               return Container(
//                 padding: EdgeInsets.all(12.r),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightGrey,
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.storage, color: AppColors.primary),
//                     8.horizontalSpace,
//                     Text(
//                       "SharedPrefs: ${snapshot.data ?? false}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.secondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
          
//           16.verticalSpace,
          
//           // Test Buttons
//           Wrap(
//             spacing: 8.w,
//             runSpacing: 8.h,
//             children: [
//               _buildTestButton(
//                 "Test SharedPrefs",
//                 () => homeController.testSharedPreferences(),
//                 Colors.blue,
//               ),
//               _buildTestButton(
//                 "Force Show Flow",
//                 () => homeController.forceShowProfileFlow(),
//                 Colors.orange,
//               ),
//               _buildTestButton(
//                 "Mark Complete",
//                 () => homeController.markProfileAsComplete(),
//                 Colors.green,
//               ),
//               _buildTestButton(
//                 "Reset Profile",
//                 () => homeController.resetProfileCompletion(),
//                 Colors.red,
//               ),
//               _buildTestButton(
//                 "Clear SharedPrefs",
//                 () => homeController.clearSharedPrefs(),
//                 Colors.purple,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestButton(String text, VoidCallback onPressed, Color color) {
//     return SizedBox(
//       width: 100.w,
//       height: 36.h,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 10.sp,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
