enum AppCurrency {
  usd(code: 'USD', symbol: r'$'),
  bdt(code: 'BDT', symbol: '৳'),
  eur(code: 'EUR', symbol: '€'),
  gbp(code: 'GBP', symbol: '£'),
  inr(code: 'INR', symbol: '₹');

  const AppCurrency({required this.code, required this.symbol});

  final String code;
  final String symbol;

  String format(double amount) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static AppCurrency fromCode(String? code) {
    return AppCurrency.values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => AppCurrency.usd,
    );
  }
}
