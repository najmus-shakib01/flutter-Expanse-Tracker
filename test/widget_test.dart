import 'dart:async';

import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/app/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the app shell and navigates between tabs', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository();
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);

    await tester.tap(find.text('Expenses'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('No expenses recorded'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.scrollUntilVisible(find.text('About'), 300);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Expense Tracker'), findsWidgets);
    expect(find.text('Version 1.0.0'), findsOneWidget);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('adds, edits, and deletes an expense', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository();
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    await tester.tap(find.text('Expenses'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.tap(find.text('Add expense'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Add Expense'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('expenseTitleField')),
      'Coffee',
    );
    await tester.enterText(find.byKey(const Key('expenseAmountField')), '4.50');
    await tester.ensureVisible(find.byKey(const Key('saveExpenseButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ExpensePreviewCard, 'Coffee'), findsOneWidget);
    expect(find.text(r'$4.50'), findsOneWidget);

    await tester.tap(find.widgetWithText(ExpensePreviewCard, 'Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);

    await tester.tap(find.byKey(const Key('editExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Expense'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('expenseTitleField')),
      'Coffee Beans',
    );
    await tester.enterText(find.byKey(const Key('expenseAmountField')), '8.75');
    await tester.ensureVisible(find.byKey(const Key('saveExpenseButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('Coffee Beans'), findsOneWidget);
    expect(find.text(r'$8.75'), findsOneWidget);

    final detailsDeleteButton = find.byKey(const Key('deleteExpenseButton'));
    await tester.ensureVisible(detailsDeleteButton);
    await tester.pump();
    await tester.tap(detailsDeleteButton);
    await tester.pumpAndSettle();
    expect(find.text('Delete expense?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmDeleteExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('No expenses recorded'), findsOneWidget);
    expect(find.text('Coffee Beans'), findsNothing);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('adds, edits, and deletes a custom category', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository();
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.scrollUntilVisible(find.text('Categories'), 300);
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsWidgets);

    await tester.tap(find.byTooltip('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('categoryNameField')),
      'Travel',
    );
    await tester.ensureVisible(find.byKey(const Key('saveCategoryButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveCategoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editCategoryButton-category-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'Trips');
    await tester.ensureVisible(find.byKey(const Key('saveCategoryButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('saveCategoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);

    await tester.tap(find.byKey(const Key('deleteCategoryButton-category-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteCategoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsNothing);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('searches, filters, and sorts expenses', (
    WidgetTester tester,
  ) async {
    final expenseRepository = _FakeExpenseRepository.withExpenses([
      _testExpense(
        id: 'expense-lunch',
        title: 'Lunch',
        amount: 12,
        categoryId: 'food',
        categoryName: 'Food',
        spentAt: DateTime(2026, 7, 23, 13),
      ),
      _testExpense(
        id: 'expense-bus',
        title: 'Bus Ticket',
        amount: 3.5,
        categoryId: 'other',
        categoryName: 'Other',
        spentAt: DateTime(2026, 7, 22, 9),
      ),
    ]);
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    await tester.tap(find.text('Expenses'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.widgetWithText(ExpensePreviewCard, 'Lunch'), findsOneWidget);
    expect(
      find.widgetWithText(ExpensePreviewCard, 'Bus Ticket'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('expenseSearchField')), 'bus');
    await tester.pump();

    expect(
      find.widgetWithText(ExpensePreviewCard, 'Bus Ticket'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ExpensePreviewCard, 'Lunch'), findsNothing);

    await tester.tap(find.byKey(const Key('clearExpenseSearchButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('categoryFilter-food')));
    await tester.pump();

    expect(find.widgetWithText(ExpensePreviewCard, 'Lunch'), findsOneWidget);
    expect(find.widgetWithText(ExpensePreviewCard, 'Bus Ticket'), findsNothing);

    await tester.tap(find.byTooltip('Clear filters'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('sortExpensesButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amount: low to high'));
    await tester.pumpAndSettle();

    final busTopLeft = tester.getTopLeft(
      find.widgetWithText(ExpensePreviewCard, 'Bus Ticket'),
    );
    final lunchTopLeft = tester.getTopLeft(
      find.widgetWithText(ExpensePreviewCard, 'Lunch'),
    );
    expect(busTopLeft.dy, lessThan(lunchTopLeft.dy));

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('dashboard shows real expense metrics and recent expenses', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final expenseRepository = _FakeExpenseRepository.withExpenses([
      _testExpense(
        id: 'expense-lunch',
        title: 'Lunch',
        amount: 12,
        categoryId: 'food',
        categoryName: 'Food',
        spentAt: DateTime(now.year, now.month, now.day, 13),
      ),
      _testExpense(
        id: 'expense-bus',
        title: 'Bus Ticket',
        amount: 3.5,
        categoryId: 'other',
        categoryName: 'Other',
        spentAt: DateTime(now.year, now.month, now.day, 9),
      ),
    ]);
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    expect(find.text(r'$15.50'), findsWidgets);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();

    expect(find.text('Recent Expenses'), findsOneWidget);
    expect(find.widgetWithText(ExpensePreviewCard, 'Lunch'), findsOneWidget);
    expect(
      find.widgetWithText(ExpensePreviewCard, 'Bus Ticket'),
      findsOneWidget,
    );

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('statistics shows monthly summary and category breakdown', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final expenseRepository = _FakeExpenseRepository.withExpenses([
      _testExpense(
        id: 'expense-lunch',
        title: 'Lunch',
        amount: 12,
        categoryId: 'food',
        categoryName: 'Food',
        spentAt: DateTime(now.year, now.month, now.day, 13),
      ),
      _testExpense(
        id: 'expense-bus',
        title: 'Bus Ticket',
        amount: 3.5,
        categoryId: 'other',
        categoryName: 'Other',
        spentAt: DateTime(now.year, now.month, now.day, 9),
      ),
    ]);
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    await tester.tap(find.text('Statistics'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Monthly Summary'), findsOneWidget);
    expect(find.text(r'$15.50'), findsOneWidget);
    expect(find.byKey(const Key('monthlyCategoryPieChart')), findsOneWidget);
    expect(find.text('Top category'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();

    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('Other'), findsWidgets);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('exports CSV preview and clears all expenses from settings', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final expenseRepository = _FakeExpenseRepository.withExpenses([
      _testExpense(
        id: 'expense-lunch',
        title: 'Lunch',
        amount: 12,
        categoryId: 'food',
        categoryName: 'Food',
        spentAt: DateTime(now.year, now.month, now.day, 13),
      ),
    ]);
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.ensureVisible(find.text('Export CSV'));
    await tester.pump();
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    expect(find.text('Export Expenses'), findsOneWidget);
    expect(find.textContaining('Title,Amount,Category'), findsOneWidget);
    expect(find.textContaining('Lunch,12.00,Food'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('clearAllExpensesButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('clearAllExpensesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Clear all expenses?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmClearExpensesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expenses'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('No expenses recorded'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });

  testWidgets('changes displayed currency from settings', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final expenseRepository = _FakeExpenseRepository.withExpenses([
      _testExpense(
        id: 'expense-lunch',
        title: 'Lunch',
        amount: 15.5,
        categoryId: 'food',
        categoryName: 'Food',
        spentAt: DateTime(now.year, now.month, now.day, 13),
      ),
    ]);
    final categoryRepository = _FakeCategoryRepository();

    await tester.pumpWidget(_testApp(expenseRepository, categoryRepository));
    await tester.pump();

    expect(find.text(r'$15.50'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.ensureVisible(find.byKey(const Key('currency-bdt')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('currency-bdt')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dashboard'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('৳15.50'), findsWidgets);

    expenseRepository.dispose();
    categoryRepository.dispose();
  });
}

Widget _testApp(
  _FakeExpenseRepository expenseRepository,
  _FakeCategoryRepository categoryRepository,
) {
  return ProviderScope(
    overrides: [
      expenseRepositoryProvider.overrideWithValue(expenseRepository),
      categoryRepositoryProvider.overrideWithValue(categoryRepository),
    ],
    child: const ExpenseTrackerApp(),
  );
}

class _FakeExpenseRepository implements ExpenseRepository {
  final _expenses = <Expense>[];
  final _controller = StreamController<List<Expense>>.broadcast();

  _FakeExpenseRepository();

  _FakeExpenseRepository.withExpenses(List<Expense> expenses) {
    _expenses.addAll(expenses);
    _expenses.sort((first, second) => second.spentAt.compareTo(first.spentAt));
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    _emit();
  }

  @override
  Future<void> clearExpenses() async {
    _expenses.clear();
    _emit();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    for (final expense in _expenses) {
      if (expense.id == id) {
        return expense;
      }
    }

    return null;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    return List.unmodifiable(_expenses);
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    _expenses.removeWhere((item) => item.id == expense.id);
    _expenses.add(expense);
    _expenses.sort((first, second) => second.spentAt.compareTo(first.spentAt));
    _emit();
  }

  @override
  Stream<List<Expense>> watchExpenses() async* {
    yield List.unmodifiable(_expenses);
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_expenses));
  }
}

Expense _testExpense({
  required String id,
  required String title,
  required double amount,
  required String categoryId,
  required String categoryName,
  required DateTime spentAt,
}) {
  final now = DateTime(2026, 7, 23, 12);

  return Expense(
    id: id,
    title: title,
    amount: amount,
    categoryId: categoryId,
    categoryName: categoryName,
    spentAt: spentAt,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeCategoryRepository implements CategoryRepository {
  final _categories = <ExpenseCategory>[
    ExpenseCategory(
      id: 'food',
      name: 'Food',
      iconCodePoint: Icons.restaurant_rounded.codePoint,
      colorValue: AppColors.accent.toARGB32(),
      createdAt: DateTime(2026, 7, 23),
      updatedAt: DateTime(2026, 7, 23),
      isSystem: true,
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Other',
      iconCodePoint: Icons.more_horiz_rounded.codePoint,
      colorValue: AppColors.mutedText.toARGB32(),
      createdAt: DateTime(2026, 7, 23),
      updatedAt: DateTime(2026, 7, 23),
      isSystem: true,
    ),
  ];
  final _controller = StreamController<List<ExpenseCategory>>.broadcast();
  var _customIdCounter = 0;

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((category) => category.id == id);
    _emit();
  }

  @override
  Future<List<ExpenseCategory>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<ExpenseCategory?> getCategoryById(String id) async {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  @override
  Future<void> saveCategory(ExpenseCategory category) async {
    final existing = await getCategoryById(category.id);
    final id = existing == null && category.id.startsWith('category-')
        ? 'category-${++_customIdCounter}'
        : category.id;
    final savedCategory = category.copyWith(id: id);

    _categories.removeWhere((item) => item.id == savedCategory.id);
    _categories.add(savedCategory);
    _categories.sort((first, second) => first.name.compareTo(second.name));
    _emit();
  }

  @override
  Stream<List<ExpenseCategory>> watchCategories() async* {
    yield List.unmodifiable(_categories);
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_categories));
  }
}
