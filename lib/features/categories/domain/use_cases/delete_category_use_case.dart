import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteCategory(id);
  }
}
