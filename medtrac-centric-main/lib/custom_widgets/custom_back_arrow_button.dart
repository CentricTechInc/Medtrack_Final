import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackArrowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const CustomBackArrowButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => onPressed ?? Get.back(),
        icon: Icon(Icons.arrow_back_ios_sharp));
  }
}
