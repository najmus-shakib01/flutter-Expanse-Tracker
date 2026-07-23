import 'package:expense_tracker/features/expenses/data/data_sources/expense_local_data_source.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._localDataSource);

  final ExpenseLocalDataSource _localDataSource;

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await _localDataSource.getExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return _localDataSource.watchExpenses().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final model = await _localDataSource.getExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveExpense(Expense expense) {
    return _localDataSource.saveExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) {
    return _localDataSource.deleteExpense(id);
  }

  @override
  Future<void> clearExpenses() {
    return _localDataSource.clearExpenses();
  }
}
