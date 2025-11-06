import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomSwitchWidget extends StatelessWidget {
  final RxBool switchValue;
  final VoidCallback onToggle;
  final bool isFixed;

  const CustomSwitchWidget({
    super.key,
    required this.switchValue,
    required this.onToggle,
    this.isFixed = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Switch(
      value: switchValue.value,
      onChanged: isFixed ? null : (value) => onToggle(), 
      activeColor: Colors.white,
      activeTrackColor: AppColors.primary,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
    ));
  }
}
