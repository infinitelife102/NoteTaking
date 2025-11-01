import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    final themeModeIndex = _prefs.getInt('themeMode') ?? AppThemeMode.system.index;
    _themeMode = AppThemeMode.values[themeModeIndex];
    _isInitialized = true;

    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_themeMode == AppThemeMode.system) {
        notifyListeners();
      }
    };

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    await _prefs.setInt('themeMode', themeMode.index);

    _updateSystemUIOverlay();

    notifyListeners();
  }

  void toggleTheme() {
    switch (_themeMode) {
      case AppThemeMode.light:
        setThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        setThemeMode(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        setThemeMode(brightness == Brightness.dark ? AppThemeMode.light : AppThemeMode.dark);
        break;
    }
  }

  void _updateSystemUIOverlay() {
    final isDark = isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  String get themeDisplayName {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData get themeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
