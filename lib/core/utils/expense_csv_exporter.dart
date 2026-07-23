import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';

abstract final class ExpenseCsvExporter {
  static String export(List<Expense> expenses) {
    final rows = [
      [
        'Title',
        'Amount',
        'Category',
        'Date',
        'Time',
        'Note',
        'Created At',
        'Updated At',
      ],
      for (final expense in expenses)
        [
          expense.title,
          expense.amount.toStringAsFixed(2),
          expense.categoryName,
          _date(expense.spentAt),
          _time(expense.spentAt),
          expense.note ?? '',
          expense.createdAt.toIso8601String(),
          expense.updatedAt.toIso8601String(),
        ],
    ];

    return rows.map(_row).join('\n');
  }

  static String _row(List<String> values) {
    return values.map(_escape).join(',');
  }

  static String _escape(String value) {
    final escapedValue = value.replaceAll('"', '""');
    if (escapedValue.contains(',') ||
        escapedValue.contains('\n') ||
        escapedValue.contains('"')) {
      return '"$escapedValue"';
    }

    return escapedValue;
  }

  static String _date(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }

  static String _time(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
