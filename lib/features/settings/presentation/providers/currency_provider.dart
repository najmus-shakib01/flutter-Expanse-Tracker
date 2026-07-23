import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/preferences/app_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyControllerProvider =
    NotifierProvider<CurrencyController, AppCurrency>(CurrencyController.new);

class CurrencyController extends Notifier<AppCurrency> {
  @override
  AppCurrency build() => AppPreferences.getCurrency();

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    await AppPreferences.setCurrency(currency);
  }
}
