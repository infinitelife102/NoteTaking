import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFDEE2E6);
  static const Color lightPrimary = Color(0xFF343A40);
  static const Color lightSecondary = Color(0xFF6C757D);
  static const Color lightAccent = Color(0xFF212529);
  static const Color lightOnBackground = Color(0xFF212529);
  static const Color lightOnSurface = Color(0xFF495057);
  static const Color lightError = Color(0xFF6C757D);
  static const Color lightSuccess = Color(0xFF495057);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFFE1E1E1);
  static const Color darkSecondary = Color(0xFFB0B0B0);
  static const Color darkAccent = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkError = Color(0xFFB0B0B0);
  static const Color darkSuccess = Color(0xFFE1E1E1);

  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color primaryfontColor = Color(0xFF212529);
  static const Color secondaryfontColor = Color(0xFF495057);
  static const Color warningColor = Color(0xFF6C757D);
  static const Color successColor = Color(0xFF495057);
}

class AppTheme {
  static final TextTheme _textTheme = GoogleFonts.poppinsTextTheme();

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _textTheme.apply(bodyColor: AppColors.lightOnBackground, displayColor: AppColors.lightOnBackground),

    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightOnSurface,
      onBackground: AppColors.lightOnBackground,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.lightOnBackground),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: AppColors.lightOnBackground, fontWeight: FontWeight.w600),
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.lightSurface,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.lightSurface,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      textStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.lightOnSurface),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightOnBackground,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.lightBackground),
      actionTextColor: AppColors.lightAccent,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightAccent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightAccent,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightSurface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightSecondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightSecondary.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightAccent, width: 2),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightPrimary,
      selectionColor: AppColors.lightPrimary.withOpacity(0.3),
      selectionHandleColor: AppColors.lightPrimary,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _textTheme.apply(bodyColor: AppColors.darkOnBackground, displayColor: AppColors.darkOnBackground),

    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkError,
      onPrimary: AppColors.darkBackground,
      onSecondary: AppColors.darkBackground,
      onSurface: AppColors.darkOnSurface,
      onBackground: AppColors.darkOnBackground,
      onError: AppColors.darkBackground,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkOnBackground),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: AppColors.darkOnBackground, fontWeight: FontWeight.w600),
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.darkSurface,
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkSurface,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      textStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.darkOnSurface),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.darkOnBackground),
      actionTextColor: AppColors.darkAccent,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkAccent,
      foregroundColor: AppColors.darkBackground,
      elevation: 4,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.darkBackground,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkSurface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkSecondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkSecondary.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkAccent, width: 2),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkPrimary,
      selectionColor: AppColors.darkPrimary.withOpacity(0.3),
      selectionHandleColor: AppColors.darkPrimary,
    ),
  );
}
