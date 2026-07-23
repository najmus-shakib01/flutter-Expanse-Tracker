import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:hive/hive.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.spentAt,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final String categoryName;
  final DateTime spentAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      categoryId: expense.categoryId,
      categoryName: expense.categoryName,
      spentAt: expense.spentAt,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      note: expense.note,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      categoryId: categoryId,
      categoryName: categoryName,
      spentAt: spentAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      note: note,
    );
  }
}

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  static const int adapterTypeId = 1;

  @override
  int get typeId => ExpenseModelAdapter.adapterTypeId;

  @override
  ExpenseModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    final now = DateTime.now();

    return ExpenseModel(
      id: _stringOrFallback(fields[0], 'legacy-${now.microsecondsSinceEpoch}'),
      title: _stringOrFallback(fields[1], 'Untitled expense'),
      amount: _doubleOrFallback(fields[2]),
      categoryId: _stringOrFallback(fields[3], 'other'),
      categoryName: _stringOrFallback(fields[4], 'Other'),
      spentAt: _dateTimeOrFallback(fields[5], now),
      createdAt: _dateTimeOrFallback(fields[6], now),
      updatedAt: _dateTimeOrFallback(fields[7], now),
      note: _nullableString(fields[8]),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.categoryName)
      ..writeByte(5)
      ..write(obj.spentAt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.note);
  }

  String _stringOrFallback(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallback;
  }

  double _doubleOrFallback(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  DateTime _dateTimeOrFallback(Object? value, DateTime fallback) {
    if (value is DateTime) {
      return value;
    }

    return fallback;
  }

  String? _nullableString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
