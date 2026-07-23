import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class WatchCategoriesUseCase {
  const WatchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Stream<List<ExpenseCategory>> call() {
    return _repository.watchCategories();
  }
}
