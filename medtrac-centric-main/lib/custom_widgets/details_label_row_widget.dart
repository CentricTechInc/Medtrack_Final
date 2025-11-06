import 'package:flutter/material.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class DetailLabelRowWidget extends StatelessWidget {
  final String title;
  final String value;
  final bool isValueBold;
  const DetailLabelRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.isValueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BodyTextOne(
          text: title,
          color: AppColors.darkGreyText,
          fontWeight: FontWeight.bold,
        ),
        BodyTextOne(
          text: value,
          color: isValueBold ? AppColors.secondary : null,
          fontWeight: isValueBold ? FontWeight.bold : null,
          fontSize: isValueBold ? 24 : null,
        ),
      ],
    );
  }
}