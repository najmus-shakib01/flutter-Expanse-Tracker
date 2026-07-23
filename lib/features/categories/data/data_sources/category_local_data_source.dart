import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:hive/hive.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Stream<List<CategoryModel>> watchCategories();

  Future<CategoryModel?> getCategoryById(String id);

  Future<void> saveCategory(CategoryModel category);

  Future<void> deleteCategory(String id);
}

class HiveCategoryLocalDataSource implements CategoryLocalDataSource {
  const HiveCategoryLocalDataSource(this._box);

  final Box<CategoryModel> _box;

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _sortedCategories();
  }

  @override
  Stream<List<CategoryModel>> watchCategories() async* {
    yield _sortedCategories();
    yield* _box.watch().map((event) => _sortedCategories());
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveCategory(CategoryModel category) {
    return _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return _box.delete(id);
  }

  List<CategoryModel> _sortedCategories() {
    final categories = _box.values.toList();
    categories.sort((first, second) {
      final systemSort = _systemSortValue(
        second,
      ).compareTo(_systemSortValue(first));
      if (systemSort != 0) {
        return systemSort;
      }

      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });
    return categories;
  }

  int _systemSortValue(CategoryModel category) => category.isSystem ? 1 : 0;
}
