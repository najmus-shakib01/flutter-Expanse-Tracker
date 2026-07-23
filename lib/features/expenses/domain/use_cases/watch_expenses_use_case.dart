import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class WatchExpensesUseCase {
  const WatchExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Stream<List<Expense>> call() {
    return _repository.watchExpenses();
  }
}
