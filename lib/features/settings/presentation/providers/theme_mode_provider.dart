import 'package:expense_tracker/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => AppPreferences.getThemeMode();

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await AppPreferences.setThemeMode(mode);
  }
}
