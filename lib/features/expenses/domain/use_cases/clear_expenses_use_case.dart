import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class ClearExpensesUseCase {
  const ClearExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call() {
    return _repository.clearExpenses();
  }
}
