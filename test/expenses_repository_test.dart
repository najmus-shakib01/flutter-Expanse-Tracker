import 'dart:io';

import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/expenses/data/data_sources/expense_local_data_source.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<ExpenseModel> box;
  late ExpenseRepositoryImpl repository;

  setUp(() async {
    tempDirectory = Directory.systemTemp.createTempSync(
      'expense_tracker_hive_test_',
    );
    Hive.init(tempDirectory.path);
    AppDatabase.registerAdapters();
    box = await Hive.openBox<ExpenseModel>('expenses_test');
    repository = ExpenseRepositoryImpl(HiveExpenseLocalDataSource(box));
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('expenses_test');
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('saves and reads expenses sorted by spent date descending', () async {
    final olderExpense = _expense(
      id: 'expense-1',
      title: 'Lunch',
      spentAt: DateTime(2026, 7, 20, 13),
    );
    final newerExpense = _expense(
      id: 'expense-2',
      title: 'Coffee',
      spentAt: DateTime(2026, 7, 21, 9),
    );

    await repository.saveExpense(olderExpense);
    await repository.saveExpense(newerExpense);

    final expenses = await repository.getExpenses();

    expect(expenses, [newerExpense, olderExpense]);
    expect(await repository.getExpenseById('expense-1'), olderExpense);
  });

  test('emits updates when expenses change and supports delete', () async {
    final expense = _expense(
      id: 'expense-1',
      title: 'Transport',
      spentAt: DateTime(2026, 7, 22, 18),
    );

    final emissions = <List<Expense>>[];
    final subscription = repository.watchExpenses().listen(emissions.add);

    await Future<void>.delayed(Duration.zero);
    await repository.saveExpense(expense);
    await Future<void>.delayed(Duration.zero);
    await repository.deleteExpense(expense.id);
    await Future<void>.delayed(Duration.zero);

    await subscription.cancel();

    expect(emissions.first, isEmpty);
    expect(emissions.any((items) => items.contains(expense)), isTrue);
    expect(await repository.getExpenseById(expense.id), isNull);
  });
}

Expense _expense({
  required String id,
  required String title,
  required DateTime spentAt,
}) {
  final now = DateTime(2026, 7, 23, 12);

  return Expense(
    id: id,
    title: title,
    amount: 120,
    categoryId: 'food',
    categoryName: 'Food',
    spentAt: spentAt,
    createdAt: now,
    updatedAt: now,
  );
}
