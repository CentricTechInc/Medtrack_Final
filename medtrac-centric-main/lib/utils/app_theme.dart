import 'package:flutter/material.dart';
import 'package:medtrac/utils/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: 'Visby',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0E121D)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bright,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightGreyText,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}