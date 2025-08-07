import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFF2E5BC);
  static const Color primaryfontColor = Color(0xFF1D2021);
  static const Color secondaryfontColor = Color(0xFF282828);
  static const Color warningColor = Color(0xFFCC241D);
  static const Color successColor = Color(0xFF98971A);
}

class AppTheme {
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.secondaryfontColor,
    primaryColor: AppColors.successColor,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.successColor,
      secondary: AppColors.warningColor,
      surface: AppColors.secondaryfontColor,
      error: AppColors.warningColor,
      onPrimary: AppColors.primaryfontColor,
      onSurface: AppColors.backgroundColor,
      onError: AppColors.primaryfontColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondaryfontColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.backgroundColor),
      titleTextStyle: TextStyle(color: AppColors.backgroundColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.secondaryfontColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      textStyle: TextStyle(color: AppColors.backgroundColor, fontSize: 14, fontWeight: FontWeight.w500),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.secondaryfontColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      contentTextStyle: TextStyle(color: AppColors.backgroundColor),
      actionTextColor: AppColors.successColor,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.successColor,
      foregroundColor: AppColors.primaryfontColor,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.successColor,
        foregroundColor: AppColors.primaryfontColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.successColor),
  );
}
