import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';

abstract interface class CategoryRepository {
  Future<List<ExpenseCategory>> getCategories();

  Stream<List<ExpenseCategory>> watchCategories();

  Future<ExpenseCategory?> getCategoryById(String id);

  Future<void> saveCategory(ExpenseCategory category);

  Future<void> deleteCategory(String id);
}
