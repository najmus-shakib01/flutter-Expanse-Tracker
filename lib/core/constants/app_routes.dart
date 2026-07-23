abstract final class AppRoutes {
  static const String dashboardName = 'dashboard';
  static const String expensesName = 'expenses';
  static const String addExpenseName = 'add-expense';
  static const String expenseDetailsName = 'expense-details';
  static const String editExpenseName = 'edit-expense';
  static const String categoriesName = 'categories';
  static const String statisticsName = 'statistics';
  static const String settingsName = 'settings';

  static const String dashboardPath = '/';
  static const String expensesPath = '/expenses';
  static const String addExpenseSubPath = 'add';
  static const String expenseDetailsSubPath = ':expenseId';
  static const String editExpenseSubPath = ':expenseId/edit';
  static const String expenseIdParam = 'expenseId';
  static const String categoriesPath = '/categories';
  static const String statisticsPath = '/statistics';
  static const String settingsPath = '/settings';
}
