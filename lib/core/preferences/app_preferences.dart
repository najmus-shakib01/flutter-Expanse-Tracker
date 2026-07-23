import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPreferences {
  static const String _themeModeKey = 'theme_mode';
  static const String _currencyCodeKey = 'currency_code';

  static SharedPreferences? _preferences;
  static final _fallbackValues = <String, Object>{};

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _fallbackValues.clear();
  }

  static ThemeMode getThemeMode() {
    final value =
        _preferences?.getString(_themeModeKey) ??
        _fallbackValues[_themeModeKey] as String?;

    return _themeModeFromName(value);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode.name;
    _fallbackValues[_themeModeKey] = value;
    await _preferences?.setString(_themeModeKey, value);
  }

  static AppCurrency getCurrency() {
    final value =
        _preferences?.getString(_currencyCodeKey) ??
        _fallbackValues[_currencyCodeKey] as String?;

    return AppCurrency.fromCode(value);
  }

  static Future<void> setCurrency(AppCurrency currency) async {
    _fallbackValues[_currencyCodeKey] = currency.code;
    await _preferences?.setString(_currencyCodeKey, currency.code);
  }

  static ThemeMode _themeModeFromName(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
