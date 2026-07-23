import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/extensions/date_time_formatting.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/models/expense_category_option.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/settings/presentation/providers/currency_provider.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpenseDetailsScreen extends ConsumerWidget {
  const ExpenseDetailsScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseByIdProvider(expenseId));
    final currency = ref.watch(currencyControllerProvider);
    final categories = ref
        .watch(categoriesStreamProvider)
        .maybeWhen(
          data: (categories) => categories,
          orElse: () => const <ExpenseCategory>[],
        );

    return PageBody(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Expense Details',
            subtitle: 'Review the saved transaction.',
            trailing: IconButton.outlined(
              tooltip: 'Back to expenses',
              onPressed: () => context.goNamed(AppRoutes.expensesName),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ...expenseAsync.when(
          data: (expense) {
            if (expense == null) {
              return const [
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Expense not found',
                    message: 'This transaction may have been removed.',
                  ),
                ),
              ];
            }

            return [
              SliverToBoxAdapter(
                child: _ExpenseDetailsCard(
                  expense: expense,
                  categories: categories,
                  currency: currency,
                  onEdit: () => context.goNamed(
                    AppRoutes.editExpenseName,
                    pathParameters: {AppRoutes.expenseIdParam: expense.id},
                  ),
                  onDelete: () => _confirmDelete(context, ref, expense),
                ),
              ),
            ];
          },
          error: (error, stackTrace) => const [
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load expense',
                message: 'Please go back and try again.',
              ),
            ),
          ],
          loading: () => const [
            SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: Text(
            'This will permanently remove "${expense.title}" from your local expense history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              key: const Key('confirmDeleteExpenseButton'),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await ref.read(deleteExpenseUseCaseProvider).call(expense.id);
    ref.invalidate(expensesStreamProvider);
    ref.invalidate(expenseByIdProvider(expense.id));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted successfully')),
    );
    context.go(AppRoutes.expensesPath);
  }
}

class _ExpenseDetailsCard extends StatelessWidget {
  const _ExpenseDetailsCard({
    required this.expense,
    required this.categories,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final List<ExpenseCategory> categories;
  final AppCurrency currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = categoryOptionById(expense.categoryId, categories);
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'expense-card-${expense.id}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          expense.categoryName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(expense.amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailRow(
                icon: Icons.calendar_month_rounded,
                label: 'Date',
                value: expense.spentAt.toShortDate(),
              ),
              const Divider(height: AppSpacing.lg),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Time',
                value: TimeOfDay.fromDateTime(expense.spentAt).toReadableTime(),
              ),
              const Divider(height: AppSpacing.lg),
              _DetailRow(
                icon: Icons.category_rounded,
                label: 'Category',
                value: expense.categoryName,
              ),
              if (expense.note != null && expense.note!.isNotEmpty) ...[
                const Divider(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.notes_rounded,
                  label: 'Note',
                  value: expense.note!,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('editExpenseButton'),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('deleteExpenseButton'),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
