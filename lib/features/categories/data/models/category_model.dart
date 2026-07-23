import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:hive/hive.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.isSystem,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;

  factory CategoryModel.fromEntity(ExpenseCategory category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconCodePoint: category.iconCodePoint,
      colorValue: category.colorValue,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      isSystem: category.isSystem,
    );
  }

  ExpenseCategory toEntity() {
    return ExpenseCategory(
      id: id,
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSystem: isSystem,
    );
  }
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  static const int adapterTypeId = 2;

  @override
  int get typeId => CategoryModelAdapter.adapterTypeId;

  @override
  CategoryModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    final now = DateTime.now();

    return CategoryModel(
      id: _stringOrFallback(
        fields[0],
        'category-${now.microsecondsSinceEpoch}',
      ),
      name: _stringOrFallback(fields[1], 'Other'),
      iconCodePoint: _intOrFallback(fields[2], 0xe5d3),
      colorValue: _intOrFallback(fields[3], 0xff64748b),
      createdAt: _dateTimeOrFallback(fields[4], now),
      updatedAt: _dateTimeOrFallback(fields[5], now),
      isSystem: fields[6] == true,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isSystem);
  }

  String _stringOrFallback(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallback;
  }

  int _intOrFallback(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }

  DateTime _dateTimeOrFallback(Object? value, DateTime fallback) {
    if (value is DateTime) {
      return value;
    }

    return fallback;
  }
}
