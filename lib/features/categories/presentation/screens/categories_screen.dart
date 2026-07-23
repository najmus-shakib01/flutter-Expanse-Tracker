import 'package:expense_tracker/app/theme/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return PageBody(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Categories',
            subtitle: 'Customize how expenses are grouped.',
            trailing: IconButton.filled(
              tooltip: 'Add category',
              onPressed: () => _openCategorySheet(context, ref),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ...categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const [
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.category_outlined,
                    title: 'No categories found',
                    message: 'Add a category to start organizing expenses.',
                  ),
                ),
              ];
            }

            return [
              SliverList.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryTile(
                    category: category,
                    onEdit: () => _openCategorySheet(context, ref, category),
                    onDelete: category.isSystem
                        ? null
                        : () => _confirmDelete(context, ref, category),
                  );
                },
              ),
            ];
          },
          error: (error, stackTrace) => const [
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load categories',
                message: 'Please restart the app and try again.',
              ),
            ),
          ],
          loading: () => const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openCategorySheet(
    BuildContext context,
    WidgetRef ref, [
    ExpenseCategory? category,
  ]) async {
    final savedCategory = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CategoryFormSheet(category: category),
    );

    if (savedCategory == null) {
      return;
    }

    await ref.read(saveCategoryUseCaseProvider).call(savedCategory);
    ref.invalidate(categoriesStreamProvider);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategory category,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'This removes "${category.name}" from category choices. Existing expenses will keep their saved category name.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            key: const Key('confirmDeleteCategoryButton'),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await ref.read(deleteCategoryUseCaseProvider).call(category.id);
    ref.invalidate(categoriesStreamProvider);
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseCategory category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          child: Icon(
            IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(category.isSystem ? 'Default category' : 'Custom'),
        trailing: Wrap(
          spacing: AppSpacing.xs,
          children: [
            IconButton(
              key: Key('editCategoryButton-${category.id}'),
              tooltip: 'Edit ${category.name}',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              key: Key('deleteCategoryButton-${category.id}'),
              tooltip: category.isSystem
                  ? 'Default categories cannot be deleted'
                  : 'Delete ${category.name}',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({this.category});

  final ExpenseCategory? category;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();

    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _selectedIconCodePoint =
        category?.iconCodePoint ?? _categoryIconChoices.first.codePoint;
    _selectedColorValue =
        category?.colorValue ?? _categoryColorChoices.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          bottomPadding + AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Category' : 'Add Category',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                key: const Key('categoryNameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                inputFormatters: [LengthLimitingTextInputFormatter(24)],
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) {
                    return 'Enter a category name';
                  }
                  if (name.length < 2) {
                    return 'Name is too short';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Education, Travel, Gifts',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Icon',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final icon in _categoryIconChoices)
                    ChoiceChip(
                      label: Icon(icon),
                      selected: _selectedIconCodePoint == icon.codePoint,
                      onSelected: (_) {
                        setState(() {
                          _selectedIconCodePoint = icon.codePoint;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Color',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final color in _categoryColorChoices)
                    _ColorChoice(
                      color: color,
                      selected: _selectedColorValue == color.toARGB32(),
                      onTap: () {
                        setState(() {
                          _selectedColorValue = color.toARGB32();
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('saveCategoryButton'),
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_isEditing ? 'Update category' : 'Save category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.category;
    final category = ExpenseCategory(
      id: existing?.id ?? 'category-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      iconCodePoint: _selectedIconCodePoint,
      colorValue: _selectedColorValue,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      isSystem: existing?.isSystem ?? false,
    );

    Navigator.of(context).pop(category);
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.onSurface : color,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    );
  }
}

const _categoryIconChoices = [
  Icons.restaurant_rounded,
  Icons.directions_bus_rounded,
  Icons.shopping_bag_rounded,
  Icons.receipt_rounded,
  Icons.health_and_safety_rounded,
  Icons.school_rounded,
  Icons.flight_takeoff_rounded,
  Icons.card_giftcard_rounded,
  Icons.savings_rounded,
  Icons.more_horiz_rounded,
];

const _categoryColorChoices = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.accent,
  AppColors.success,
  AppColors.danger,
  AppColors.mutedText,
];
