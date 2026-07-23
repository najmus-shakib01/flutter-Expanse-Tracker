import 'package:expense_tracker/features/categories/data/data_sources/category_local_data_source.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Future<List<ExpenseCategory>> getCategories() async {
    final models = await _localDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<ExpenseCategory>> watchCategories() {
    return _localDataSource.watchCategories().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<ExpenseCategory?> getCategoryById(String id) async {
    final model = await _localDataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveCategory(ExpenseCategory category) {
    return _localDataSource.saveCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) {
    return _localDataSource.deleteCategory(id);
  }
}
