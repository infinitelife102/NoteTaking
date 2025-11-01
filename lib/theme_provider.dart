import 'package:flutter/material.dart';
import 'theme.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  final AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;

  ThemeData get currentTheme {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  bool get isDarkMode {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;

    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      notifyListeners();
    };

    notifyListeners();
  }

  String get themeDisplayName => 'System';

  IconData get themeIcon => Icons.brightness_auto;
}
