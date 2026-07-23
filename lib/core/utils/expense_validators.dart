abstract final class ExpenseValidators {
  static String? title(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Enter an expense title';
    }
    if (trimmedValue.length < 2) {
      return 'Title is too short';
    }

    return null;
  }

  static String? amount(String? value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Enter an amount';
    }

    final parsedAmount = double.tryParse(trimmedValue);
    if (parsedAmount == null) {
      return 'Enter a valid number';
    }
    if (parsedAmount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }
}
