import 'package:expense_tracker/app/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:flutter/material.dart';

class ExpenseCategoryOption {
  const ExpenseCategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

const expenseCategoryOptions = [
  ExpenseCategoryOption(
    id: 'food',
    name: 'Food',
    icon: Icons.restaurant_rounded,
    color: AppColors.accent,
  ),
  ExpenseCategoryOption(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_bus_rounded,
    color: AppColors.secondary,
  ),
  ExpenseCategoryOption(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: AppColors.primary,
  ),
  ExpenseCategoryOption(
    id: 'bills',
    name: 'Bills',
    icon: Icons.receipt_rounded,
    color: AppColors.danger,
  ),
  ExpenseCategoryOption(
    id: 'health',
    name: 'Health',
    icon: Icons.health_and_safety_rounded,
    color: AppColors.success,
  ),
  ExpenseCategoryOption(
    id: 'other',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: AppColors.mutedText,
  ),
];

ExpenseCategoryOption categoryOptionFromEntity(ExpenseCategory category) {
  return ExpenseCategoryOption(
    id: category.id,
    name: category.name,
    icon: IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
    color: Color(category.colorValue),
  );
}

ExpenseCategoryOption categoryOptionById(
  String id, [
  List<ExpenseCategory> categories = const [],
]) {
  for (final category in categories) {
    if (category.id == id) {
      return categoryOptionFromEntity(category);
    }
  }

  return expenseCategoryOptions.firstWhere(
    (category) => category.id == id,
    orElse: () => expenseCategoryOptions.last,
  );
}
