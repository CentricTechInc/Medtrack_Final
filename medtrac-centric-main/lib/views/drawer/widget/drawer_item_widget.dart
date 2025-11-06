import 'package:flutter/material.dart';
import 'package:medtrac/utils/app_colors.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

   const DrawerItem({
    super.key,
    required this.title,
    required this.onTap,
    this.titleColor

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: ListTile(
        title: Text(title , style: TextStyle(color: title == "Delete Account" ? AppColors.deleteAccButtonColor : AppColors.bright , fontWeight: FontWeight.w700),),
        tileColor: titleColor ??  AppColors.primary,
        onTap: onTap,
      ),
    );
  }
}
