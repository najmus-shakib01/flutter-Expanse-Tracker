import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Stream<List<Expense>> watchExpenses();

  Future<Expense?> getExpenseById(String id);

  Future<void> saveExpense(Expense expense);

  Future<void> deleteExpense(String id);

  Future<void> clearExpenses();
}
