import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<List<ExpenseCategory>> call() {
    return _repository.getCategories();
  }
}
