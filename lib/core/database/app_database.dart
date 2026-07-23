import 'package:expense_tracker/core/database/hive_box_names.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/presentation/models/expense_category_option.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract final class AppDatabase {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    registerAdapters();
    await openBoxes();
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(ExpenseModelAdapter.adapterTypeId)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(CategoryModelAdapter.adapterTypeId)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
  }

  static Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(HiveBoxNames.expenses)) {
      await _openBoxWithRecovery<ExpenseModel>(HiveBoxNames.expenses);
    }
    if (!Hive.isBoxOpen(HiveBoxNames.categories)) {
      await _openBoxWithRecovery<CategoryModel>(HiveBoxNames.categories);
    }
    await _repairCategories();
    await _seedDefaultCategories();
  }

  static Box<ExpenseModel> get expensesBox {
    return Hive.box<ExpenseModel>(HiveBoxNames.expenses);
  }

  static Box<CategoryModel> get categoriesBox {
    return Hive.box<CategoryModel>(HiveBoxNames.categories);
  }

  static Future<void> _seedDefaultCategories() async {
    final box = categoriesBox;
    final now = DateTime.now();

    for (final category in expenseCategoryOptions) {
      if (box.containsKey(category.id)) {
        continue;
      }

      await box.put(
        category.id,
        CategoryModel(
          id: category.id,
          name: category.name,
          iconCodePoint: category.icon.codePoint,
          colorValue: category.color.toARGB32(),
          createdAt: now,
          updatedAt: now,
          isSystem: true,
        ),
      );
    }
  }

  static Future<void> _repairCategories() async {
    final box = categoriesBox;
    final defaultCategoryIds = expenseCategoryOptions
        .map((category) => category.id)
        .toSet();
    final keysToDelete = <dynamic>[];
    final customOtherKeys = <dynamic>[];
    var hasDefaultCategory = false;

    for (final key in box.keys) {
      final category = box.get(key);
      if (category == null) {
        keysToDelete.add(key);
        continue;
      }

      if (defaultCategoryIds.contains(category.id)) {
        hasDefaultCategory = true;
      }

      final isCustomOther =
          !category.isSystem && category.name.trim().toLowerCase() == 'other';
      if (isCustomOther) {
        customOtherKeys.add(key);
      }

      final isBrokenLegacyOther =
          !defaultCategoryIds.contains(category.id) &&
          category.name.trim().toLowerCase() == 'other' &&
          category.iconCodePoint == 0xe5d3 &&
          category.colorValue == 0xff64748b;

      if (isBrokenLegacyOther) {
        keysToDelete.add(key);
      }
    }

    if (!hasDefaultCategory && customOtherKeys.isNotEmpty) {
      keysToDelete.addAll(customOtherKeys);
    }

    if (customOtherKeys.length > 1) {
      keysToDelete.addAll(customOtherKeys);
    }

    final uniqueKeysToDelete = keysToDelete.toSet();
    for (final key in uniqueKeysToDelete) {
      await box.delete(key);
    }
  }

  static Future<Box<T>> _openBoxWithRecovery<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(boxName);
      return Hive.openBox<T>(boxName);
    }
  }
}
