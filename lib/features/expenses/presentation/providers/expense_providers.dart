import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/expenses/data/data_sources/expense_local_data_source.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/clear_expenses_use_case.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/delete_expense_use_case.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/get_expense_by_id_use_case.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/get_expenses_use_case.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/save_expense_use_case.dart';
import 'package:expense_tracker/features/expenses/domain/use_cases/watch_expenses_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return HiveExpenseLocalDataSource(AppDatabase.expensesBox);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource);
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final watchExpensesUseCaseProvider = Provider<WatchExpensesUseCase>((ref) {
  return WatchExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpenseByIdUseCaseProvider = Provider<GetExpenseByIdUseCase>((ref) {
  return GetExpenseByIdUseCase(ref.watch(expenseRepositoryProvider));
});

final saveExpenseUseCaseProvider = Provider<SaveExpenseUseCase>((ref) {
  return SaveExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final clearExpensesUseCaseProvider = Provider<ClearExpensesUseCase>((ref) {
  return ClearExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(watchExpensesUseCaseProvider).call();
});

final expenseByIdProvider = FutureProvider.family<Expense?, String>((
  ref,
  expenseId,
) {
  return ref.watch(getExpenseByIdUseCaseProvider).call(expenseId);
});
