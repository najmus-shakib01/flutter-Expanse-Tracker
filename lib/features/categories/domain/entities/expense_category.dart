class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;

  ExpenseCategory copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
