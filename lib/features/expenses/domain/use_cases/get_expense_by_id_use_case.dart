import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseByIdUseCase {
  const GetExpenseByIdUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Expense?> call(String id) {
    return _repository.getExpenseById(id);
  }
}
