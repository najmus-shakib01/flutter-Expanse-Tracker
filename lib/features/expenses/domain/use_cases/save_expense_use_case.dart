import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpenseUseCase {
  const SaveExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(Expense expense) {
    return _repository.saveExpense(expense);
  }
}
