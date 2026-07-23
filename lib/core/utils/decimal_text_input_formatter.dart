import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = newValue.text;

    if (value.isEmpty) {
      return newValue;
    }

    final expression = RegExp('^\\d*\\.?\\d{0,$decimalRange}\$');

    return expression.hasMatch(value) ? newValue : oldValue;
  }
}
