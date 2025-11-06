import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_account_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class HorizontalCreditCardsWidget extends StatelessWidget {
  final UserAccountInfoController controller;

  const HorizontalCreditCardsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160.h,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.savedCreditCards.length +
                    1, // +1 for add card button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Add new card button
                    return _buildAddCardWidget();
                  } else {
                    // Credit card widget
                    final card = controller.savedCreditCards[index - 1];
                    return _buildCreditCardWidget(card);
                  }
                },
              )),
        ),
      ],
    );
  }

  Widget _buildAddCardWidget() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.userAddNewPaymentMethodScreen),
      child: Container(
        width: 60.w,
        height: 140.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.secondary,
            borderRadius: 12.r,
            dashWidth: 6,
            dashSpace: 4,
            strokeWidth: 2.0,
          ),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: AppColors.secondary,
              size: 32.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardWidget(SavedCreditCard card) {
    return Container(
      width: 140.w,
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with card icon and dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 24.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Image.asset(
                    Assets.creditCardIcon,
                    width: 24.w,
                    height: 16.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 12.sp,
                      );
                    },
                  ),
                ),
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 4.w,
                      height: 4.h,
                      margin: EdgeInsets.only(left: 2.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            12.verticalSpace,

            // Card number (last 4 digits)
            BodyTextTwo(
              text:
                  "•••• ${card.cardNumber.substring(card.cardNumber.length - 4)}",
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),

            const Spacer(),

            // Card type and level
            BodyTextTwo(
              text: card.cardType,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            2.verticalSpace,
            BodyTextTwo(
              text: card.cardLevel,
              color: AppColors.lightGreyText,
              fontWeight: FontWeight.w500,
            ),

            8.verticalSpace,

            // Card type logo
            Align(
              alignment: Alignment.bottomRight,
              child: _getCardTypeLogo(card.cardType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCardTypeLogo(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'mastercard':
        return SizedBox(
          width: 28.w,
          height: 18.h,
          child: Image.asset(
            Assets.masterCardLogo,
            width: 28.w,
            height: 18.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to custom mastercard design
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 14.w,
                      height: 18.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEB001B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 14.w,
                      height: 18.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF79E1B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      case 'visa':
        return Container(
          width: 28.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: const Color(0xFF1A1F71),
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return Container(
          width: 28.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: Icon(
            Icons.credit_card,
            color: Colors.white,
            size: 12.sp,
          ),
        );
    }
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rRect);
    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, distance + len),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
