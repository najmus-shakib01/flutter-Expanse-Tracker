import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteExpense(id);
  }
}
