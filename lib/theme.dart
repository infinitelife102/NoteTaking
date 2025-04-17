import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Color(0xFFFBF1C7);
  static const Color black = Color(0xFF1D2021);

  static const Color grey850 = Color(0xFF282828);
  static const Color grey900 = Color(0xFF1D2021);

  static const Color red = Color(0xFFCC241D);
  static const Color redAccent = Color(0xFFFB4934);

  static const Color green = Color(0xFF98971A);
  static const Color green800 = Color(0xFFB8BB26);
}

class AppTheme {
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.grey850,
    primaryColor: AppColors.green,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.green800,
      secondary: AppColors.redAccent,
      background: AppColors.grey900,
      error: AppColors.redAccent,
      onPrimary: AppColors.black,
      onBackground: AppColors.white,
      onError: AppColors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.grey900,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.grey900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.grey900,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentTextStyle: TextStyle(color: AppColors.white),
      actionTextColor: AppColors.green800,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.green,
      foregroundColor: AppColors.black,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.green800,
    ),
  );
}
