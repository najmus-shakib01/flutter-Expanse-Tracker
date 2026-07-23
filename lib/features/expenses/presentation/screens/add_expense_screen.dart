import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/extensions/date_time_formatting.dart';
import 'package:expense_tracker/core/utils/decimal_text_input_formatter.dart';
import 'package:expense_tracker/core/utils/expense_validators.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/models/expense_category_option.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.initialExpense});

  final Expense? initialExpense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategoryOption _selectedCategory = expenseCategoryOptions.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();

    final expense = widget.initialExpense;
    if (expense == null) {
      return;
    }

    _titleController.text = expense.title;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _noteController.text = expense.note ?? '';
    _selectedCategory = categoryOptionById(expense.categoryId);
    _selectedDate = expense.spentAt;
    _selectedTime = TimeOfDay.fromDateTime(expense.spentAt);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoryOptions = _categoryOptionsFromAsync(categoriesAsync);

    return PageBody(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: _isEditing ? 'Edit Expense' : 'Add Expense',
            subtitle: _isEditing
                ? 'Update the saved transaction.'
                : 'Save a transaction to your local expense history.',
            trailing: IconButton.outlined(
              tooltip: 'Back',
              onPressed: () => context.go(AppRoutes.expensesPath),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(child: _buildForm(context, categoryOptions)),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<ExpenseCategoryOption> categoryOptions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            children: [
              TextFormField(
                key: const Key('expenseTitleField'),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                validator: ExpenseValidators.title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Lunch, bus fare, groceries',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                key: const Key('expenseAmountField'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [DecimalTextInputFormatter()],
                validator: ExpenseValidators.amount,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategorySelector(
                category: _selectedCategory,
                onTap: () => _showCategoryPicker(categoryOptions),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(_selectedDate.toShortDate()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(_selectedTime.toReadableTime()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('saveExpenseButton'),
                  onPressed: _isSaving ? null : _saveExpense,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? (_isEditing ? 'Updating...' : 'Saving...')
                        : (_isEditing ? 'Update expense' : 'Save expense'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime == null || !mounted) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  Future<void> _showCategoryPicker(
    List<ExpenseCategoryOption> categoryOptions,
  ) async {
    final selectedCategory = await showModalBottomSheet<ExpenseCategoryOption>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            itemCount: categoryOptions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final category = categoryOptions[index];
              final selected = category.id == _selectedCategory.id;

              return ListTile(
                selected: selected,
                leading: CircleAvatar(
                  backgroundColor: category.color.withValues(alpha: 0.14),
                  foregroundColor: category.color,
                  child: Icon(category.icon),
                ),
                title: Text(category.name),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => Navigator.of(context).pop(category),
              );
            },
          ),
        );
      },
    );

    if (selectedCategory == null || !mounted) {
      return;
    }

    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  List<ExpenseCategoryOption> _categoryOptionsFromAsync(
    AsyncValue<List<ExpenseCategory>> categoriesAsync,
  ) {
    final options = categoriesAsync.maybeWhen(
      data: (categories) => categories.map(categoryOptionFromEntity).toList(),
      orElse: () => expenseCategoryOptions,
    );

    if (options.isEmpty) {
      return expenseCategoryOptions;
    }

    final selectedStillExists = options.any(
      (category) => category.id == _selectedCategory.id,
    );
    if (!selectedStillExists) {
      _selectedCategory = options.first;
    }

    return options;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final spentAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final expense = Expense(
      id: widget.initialExpense?.id ?? 'expense-${now.microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      categoryId: _selectedCategory.id,
      categoryName: _selectedCategory.name,
      spentAt: spentAt,
      createdAt: widget.initialExpense?.createdAt ?? now,
      updatedAt: now,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      await ref.read(saveExpenseUseCaseProvider).call(expense);
      ref.invalidate(expensesStreamProvider);
      if (_isEditing) {
        ref.invalidate(expenseByIdProvider(expense.id));
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully'
                : 'Expense saved successfully',
          ),
        ),
      );
      if (_isEditing) {
        context.goNamed(
          AppRoutes.expenseDetailsName,
          pathParameters: {AppRoutes.expenseIdParam: widget.initialExpense!.id},
        );
      } else {
        context.go(AppRoutes.expensesPath);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save expense')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.category, required this.onTap});

  final ExpenseCategoryOption category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Category',
          prefixIcon: Icon(Icons.category_rounded),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 18, color: category.color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(category.name)),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
