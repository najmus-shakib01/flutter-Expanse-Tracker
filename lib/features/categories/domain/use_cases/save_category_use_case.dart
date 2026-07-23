import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class SaveCategoryUseCase {
  const SaveCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(ExpenseCategory category) {
    return _repository.saveCategory(category);
  }
}
