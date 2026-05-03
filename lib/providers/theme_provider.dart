import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/hive_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier()
      : super(HiveService.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggle() {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    HiveService.setDarkMode(newMode == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
