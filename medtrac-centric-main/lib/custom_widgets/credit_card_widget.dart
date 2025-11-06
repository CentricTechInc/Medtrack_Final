import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class CreditCardWidget extends StatelessWidget {
  final String cardNumber;
  final String cardHolderName;
  final String expirationDate;
  final String cvv;

  const CreditCardWidget({
    super.key,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.cvv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 192.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 3.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with card icon and dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 40.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Image.asset(Assets.creditCardIcon)),
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.only(left: 4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            24.verticalSpace,

            // Card number
            HeadingTextTwo(
              text: _formatCardNumber(cardNumber),
              color: AppColors.bright,
            ),

            const Spacer(),

            // Bottom row with cardholder name and logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextTwo(
                        text: 'Card Holder',
                        color: AppColors.lightGreyText,
                        fontWeight: FontWeight.bold,
                      ),
                      4.verticalSpace,
                      BodyTextOne(
                        text: cardHolderName.isEmpty
                            ? 'Your Name Here'
                            : cardHolderName,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bright,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                16.horizontalSpace,

                // Card type logo
                _getCardTypeLogo(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    // Remove all spaces and non-digits
    String cleaned = number.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) {
      return '●●●● ●●●● ●●●● ●●●●';
    }

    // Create formatted string with dots for missing digits
    String formatted = '';
    int maxLength = 16;

    for (int i = 0; i < maxLength; i += 4) {
      if (i > 0) formatted += '  ';

      for (int j = 0; j < 4; j++) {
        int digitIndex = i + j;
        if (digitIndex < cleaned.length) {
          formatted += cleaned[digitIndex];
        } else {
          formatted += '•';
        }
      }
    }

    return formatted;
  }

  CardType _getCardType(String number) {
    String cleaned = number.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return CardType.mastercard;

    // Visa: starts with 4
    if (cleaned.startsWith('4')) return CardType.visa;

    // MasterCard: starts with 5 or 2221-2720
    if (cleaned.startsWith('5') ||
        (cleaned.length >= 4 &&
            int.tryParse(cleaned.substring(0, 4)) != null &&
            int.parse(cleaned.substring(0, 4)) >= 2221 &&
            int.parse(cleaned.substring(0, 4)) <= 2720)) {
      return CardType.mastercard;
    }

    // American Express: starts with 34 or 37
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardType.amex;
    }

    // Discover: starts with 6011 or 65
    if (cleaned.startsWith('6011') || cleaned.startsWith('65')) {
      return CardType.discover;
    }

    return CardType.unknown;
  }

  Widget _getCardTypeLogo() {
    CardType type = _getCardType(cardNumber);

    switch (type) {
      case CardType.mastercard:
        return SizedBox(
          width: 40.w,
          height: 25.h,
          child: Image.asset(
            Assets.masterCardLogo,
            width: 40.w,
            height: 25.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to custom mastercard design
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 20.w,
                      height: 25.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEB001B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 20.w,
                      height: 25.h,
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
      case CardType.visa:
        return Container(
          width: 40.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: BodyTextOne(
              text: 'VISA',
              color: AppColors.bright,
            ),
          ),
        );
      case CardType.amex:
        return Container(
          width: 40.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: const Color(0xFF006FCF),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: BodyTextOne(
              text: 'AMEX',
              color: AppColors.bright,
            ),
          ),
        );
      default:
        return Container(
          width: 40.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(
            Icons.credit_card,
            color: Colors.white,
            size: 16.sp,
          ),
        );
    }
  }
}

enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  unknown,
}
