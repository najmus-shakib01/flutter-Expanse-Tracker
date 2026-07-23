import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/extensions/date_time_formatting.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/models/expense_category_option.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_preview_card.dart';
import 'package:expense_tracker/features/settings/presentation/providers/currency_provider.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  String? _selectedCategoryId;
  var _sortOption = _ExpenseSortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final currency = ref.watch(currencyControllerProvider);
    final categories = ref
        .watch(categoriesStreamProvider)
        .maybeWhen(data: (categories) => categories, orElse: () => null);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(expensesStreamProvider);
        await ref.read(expensesStreamProvider.future);
      },
      child: PageBody(
        slivers: [
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Expenses',
              subtitle: 'Search, filter, and sort your spending history.',
              trailing: IconButton.filledTonal(
                tooltip: 'Clear filters',
                onPressed: _hasActiveFilters ? _clearFilters : null,
                icon: const Icon(Icons.filter_alt_off_rounded),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          ...expensesAsync.when(
            data: (expenses) {
              final categoryList = categories ?? const <ExpenseCategory>[];
              final visibleExpenses = _applyFiltersAndSort(
                expenses,
                categoryList,
                currency,
              );

              return [
                if (expenses.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _ExpenseFilterToolbar(
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      selectedCategoryId: _selectedCategoryId,
                      sortOption: _sortOption,
                      categories: categoryList,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      onCategorySelected: (categoryId) {
                        setState(() {
                          _selectedCategoryId = categoryId;
                        });
                      },
                      onSortChanged: (sortOption) {
                        setState(() {
                          _sortOption = sortOption;
                        });
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                ],
                ..._buildExpenseContent(
                  context,
                  expenses,
                  visibleExpenses,
                  categoryList,
                  currency,
                ),
              ];
            },
            error: (error, stackTrace) => [
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load expenses',
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
      ),
    );
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategoryId != null ||
        _sortOption != _ExpenseSortOption.newest;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategoryId = null;
      _sortOption = _ExpenseSortOption.newest;
    });
  }

  List<Widget> _buildExpenseContent(
    BuildContext context,
    List<Expense> allExpenses,
    List<Expense> visibleExpenses,
    List<ExpenseCategory> categories,
    AppCurrency currency,
  ) {
    if (allExpenses.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No expenses recorded',
            message:
                'Add your first expense to start building a useful spending history.',
            action: FilledButton.icon(
              onPressed: () => context.goNamed(AppRoutes.addExpenseName),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            ),
          ),
        ),
      ];
    }

    if (visibleExpenses.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching expenses',
            message: 'Try a different search term or filter.',
            action: OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Clear filters'),
            ),
          ),
        ),
      ];
    }

    final groups = _groupExpensesByDate(visibleExpenses);

    return [
      for (final group in groups) ...[
        SliverToBoxAdapter(
          child: _ExpenseGroupHeader(
            label: group.label,
            total: group.total,
            count: group.expenses.length,
            currency: currency,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        SliverList.separated(
          itemCount: group.expenses.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final expense = group.expenses[index];
            final category = categoryOptionById(expense.categoryId, categories);
            final note = expense.note == null || expense.note!.isEmpty
                ? expense.categoryName
                : '${expense.categoryName} - ${expense.note}';

            return ExpensePreviewCard(
              title: expense.title,
              subtitle:
                  '${TimeOfDay.fromDateTime(expense.spentAt).toReadableTime()} - $note',
              amount: currency.format(expense.amount),
              icon: category.icon,
              color: category.color,
              heroTag: 'expense-card-${expense.id}',
              onTap: () => context.goNamed(
                AppRoutes.expenseDetailsName,
                pathParameters: {AppRoutes.expenseIdParam: expense.id},
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    ];
  }

  List<Expense> _applyFiltersAndSort(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    AppCurrency currency,
  ) {
    final query = _searchQuery.toLowerCase();
    final filteredExpenses = expenses.where((expense) {
      final matchesCategory =
          _selectedCategoryId == null ||
          expense.categoryId == _selectedCategoryId;
      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final category = categoryOptionById(expense.categoryId, categories);
      final searchableText = [
        expense.title,
        expense.categoryName,
        category.name,
        expense.note ?? '',
        expense.amount.toStringAsFixed(2),
        currency.format(expense.amount),
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();

    filteredExpenses.sort((first, second) {
      return switch (_sortOption) {
        _ExpenseSortOption.newest => second.spentAt.compareTo(first.spentAt),
        _ExpenseSortOption.oldest => first.spentAt.compareTo(second.spentAt),
        _ExpenseSortOption.amountHighToLow => second.amount.compareTo(
          first.amount,
        ),
        _ExpenseSortOption.amountLowToHigh => first.amount.compareTo(
          second.amount,
        ),
        _ExpenseSortOption.titleAZ => first.title.toLowerCase().compareTo(
          second.title.toLowerCase(),
        ),
      };
    });

    return filteredExpenses;
  }

  List<_ExpenseDateGroup> _groupExpensesByDate(List<Expense> expenses) {
    final groups = <DateTime, List<Expense>>{};

    for (final expense in expenses) {
      final dateKey = DateTime(
        expense.spentAt.year,
        expense.spentAt.month,
        expense.spentAt.day,
      );
      groups.putIfAbsent(dateKey, () => []).add(expense);
    }

    return groups.entries.map((entry) {
      final total = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      return _ExpenseDateGroup(
        label: entry.key.toShortDate(),
        total: total,
        expenses: entry.value,
      );
    }).toList();
  }
}

class _ExpenseFilterToolbar extends StatelessWidget {
  const _ExpenseFilterToolbar({
    required this.searchController,
    required this.searchQuery,
    required this.selectedCategoryId,
    required this.sortOption,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedCategoryId;
  final _ExpenseSortOption sortOption;
  final List<ExpenseCategory> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<_ExpenseSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final categoryOptions = categories.map(categoryOptionFromEntity).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TextField(
              key: const Key('expenseSearchField'),
              controller: searchController,
              textInputAction: TextInputAction.search,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search expenses',
                hintText: 'Search by title, category, note, amount',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        key: const Key('clearExpenseSearchButton'),
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          key: const Key('categoryFilter-all'),
                          label: const Text('All'),
                          selected: selectedCategoryId == null,
                          onSelected: (_) => onCategorySelected(null),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        for (final category in categoryOptions) ...[
                          FilterChip(
                            key: Key('categoryFilter-${category.id}'),
                            avatar: Icon(category.icon, size: 18),
                            label: Text(category.name),
                            selected: selectedCategoryId == category.id,
                            onSelected: (_) => onCategorySelected(category.id),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PopupMenuButton<_ExpenseSortOption>(
                  key: const Key('sortExpensesButton'),
                  tooltip: 'Sort expenses',
                  icon: const Icon(Icons.sort_rounded),
                  initialValue: sortOption,
                  onSelected: onSortChanged,
                  itemBuilder: (context) => [
                    for (final option in _ExpenseSortOption.values)
                      PopupMenuItem(value: option, child: Text(option.label)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseGroupHeader extends StatelessWidget {
  const _ExpenseGroupHeader({
    required this.label,
    required this.total,
    required this.count,
    required this.currency,
  });

  final String label;
  final double total;
  final int count;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'item' : 'items'} - ${currency.format(total)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ExpenseDateGroup {
  const _ExpenseDateGroup({
    required this.label,
    required this.total,
    required this.expenses,
  });

  final String label;
  final double total;
  final List<Expense> expenses;
}

enum _ExpenseSortOption {
  newest('Newest first'),
  oldest('Oldest first'),
  amountHighToLow('Amount: high to low'),
  amountLowToHigh('Amount: low to high'),
  titleAZ('Title: A to Z');

  const _ExpenseSortOption(this.label);

  final String label;
}
