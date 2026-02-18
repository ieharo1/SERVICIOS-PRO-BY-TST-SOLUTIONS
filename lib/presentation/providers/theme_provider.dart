import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) {
  return SettingsRepository();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ThemeNotifier(repository);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repository;

  ThemeNotifier(this._repository) : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _repository.isDarkMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newValue = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _repository.setDarkMode(newValue == ThemeMode.dark);
    state = newValue;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _repository.setDarkMode(isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
