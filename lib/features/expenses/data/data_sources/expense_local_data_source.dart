import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:hive/hive.dart';

abstract interface class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();

  Stream<List<ExpenseModel>> watchExpenses();

  Future<ExpenseModel?> getExpenseById(String id);

  Future<void> saveExpense(ExpenseModel expense);

  Future<void> deleteExpense(String id);

  Future<void> clearExpenses();
}

class HiveExpenseLocalDataSource implements ExpenseLocalDataSource {
  const HiveExpenseLocalDataSource(this._box);

  final Box<ExpenseModel> _box;

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    return _sortedExpenses();
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses() async* {
    yield _sortedExpenses();
    yield* _box.watch().map((event) => _sortedExpenses());
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) {
    return _box.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    return _box.delete(id);
  }

  @override
  Future<void> clearExpenses() {
    return _box.clear();
  }

  List<ExpenseModel> _sortedExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((first, second) => second.spentAt.compareTo(first.spentAt));
    return expenses;
  }
}
