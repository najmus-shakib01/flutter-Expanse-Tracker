import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/categories/data/data_sources/category_local_data_source.dart';
import 'package:expense_tracker/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:expense_tracker/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:expense_tracker/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:expense_tracker/features/categories/domain/use_cases/watch_categories_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return HiveCategoryLocalDataSource(AppDatabase.categoriesBox);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final watchCategoriesUseCaseProvider = Provider<WatchCategoriesUseCase>((ref) {
  return WatchCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final saveCategoryUseCaseProvider = Provider<SaveCategoryUseCase>((ref) {
  return SaveCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final categoriesStreamProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
});
