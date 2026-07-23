class Expense {
  const Expense({
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

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    String? categoryName,
    DateTime? spentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      spentAt: spentAt ?? this.spentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Expense &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            amount == other.amount &&
            categoryId == other.categoryId &&
            categoryName == other.categoryName &&
            spentAt == other.spentAt &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            note == other.note;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    amount,
    categoryId,
    categoryName,
    spentAt,
    createdAt,
    updatedAt,
    note,
  );
}
