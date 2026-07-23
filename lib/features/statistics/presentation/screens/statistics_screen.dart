import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/models/expense_category_option.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/settings/presentation/providers/currency_provider.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final currency = ref.watch(currencyControllerProvider);
    final categories = ref
        .watch(categoriesStreamProvider)
        .maybeWhen(
          data: (categories) => categories,
          orElse: () => const <ExpenseCategory>[],
        );

    return PageBody(
      slivers: [
        const SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Statistics',
            subtitle: 'Monthly summary and category breakdown.',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ...expensesAsync.when(
          data: (expenses) =>
              _buildStatistics(context, expenses, categories, currency),
          error: (error, stackTrace) => const [
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load statistics',
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

  List<Widget> _buildStatistics(
    BuildContext context,
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    AppCurrency currency,
  ) {
    final summary = _MonthlyStatistics.fromExpenses(expenses, categories);

    if (summary.monthlyExpenses.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'No monthly statistics yet',
            message: 'Add an expense this month to see charts and summaries.',
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: _PieChartCard(summary: summary, currency: currency),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
      SliverGrid(
        delegate: SliverChildListDelegate.fixed([
          _StatCard(
            label: 'Top category',
            value: summary.topCategory?.name ?? '-',
          ),
          _StatCard(
            label: 'Daily average',
            value: currency.format(summary.dailyAverage),
          ),
          _StatCard(
            label: 'Highest spend',
            value: currency.format(summary.highestSpend),
          ),
          _StatCard(
            label: 'Entries',
            value: summary.monthlyExpenses.length.toString(),
          ),
        ]),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 118,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      const SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Category Breakdown',
          subtitle: 'This month by spending category.',
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
      SliverList.separated(
        itemCount: summary.categoryTotals.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = summary.categoryTotals[index];
          return _CategoryBreakdownTile(
            item: item,
            totalSpend: summary.totalSpend,
            currency: currency,
          );
        },
      ),
    ];
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({required this.summary, required this.currency});

  final _MonthlyStatistics summary;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  currency.format(summary.totalSpend),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: PieChart(
                key: const Key('monthlyCategoryPieChart'),
                PieChartData(
                  centerSpaceRadius: 46,
                  sectionsSpace: 3,
                  sections: [
                    for (final item in summary.categoryTotals)
                      PieChartSectionData(
                        value: item.total,
                        title:
                            '${item.percentage(summary.totalSpend).round()}%',
                        radius: 72,
                        color: item.category.color,
                        titleStyle: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Based on ${summary.monthlyExpenses.length} transactions this month.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownTile extends StatelessWidget {
  const _CategoryBreakdownTile({
    required this.item,
    required this.totalSpend,
    required this.currency,
  });

  final _CategoryTotal item;
  final double totalSpend;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = item.percentage(totalSpend);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.category.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.category.icon, color: item.category.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      color: item.category.color,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${percentage.round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStatistics {
  const _MonthlyStatistics({
    required this.monthlyExpenses,
    required this.categoryTotals,
    required this.totalSpend,
    required this.dailyAverage,
    required this.highestSpend,
    this.topCategory,
  });

  final List<Expense> monthlyExpenses;
  final List<_CategoryTotal> categoryTotals;
  final double totalSpend;
  final double dailyAverage;
  final double highestSpend;
  final ExpenseCategoryOption? topCategory;

  factory _MonthlyStatistics.fromExpenses(
    List<Expense> expenses,
    List<ExpenseCategory> categories,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final monthlyExpenses = expenses.where((expense) {
      return !expense.spentAt.isBefore(monthStart) &&
          expense.spentAt.isBefore(nextMonth);
    }).toList();

    final totalsByCategory = <String, double>{};
    for (final expense in monthlyExpenses) {
      totalsByCategory.update(
        expense.categoryId,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final categoryTotals = totalsByCategory.entries.map((entry) {
      return _CategoryTotal(
        category: categoryOptionById(entry.key, categories),
        total: entry.value,
      );
    }).toList()..sort((first, second) => second.total.compareTo(first.total));

    final totalSpend = monthlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final highestSpend = monthlyExpenses.fold<double>(
      0,
      (highest, expense) => expense.amount > highest ? expense.amount : highest,
    );

    return _MonthlyStatistics(
      monthlyExpenses: monthlyExpenses,
      categoryTotals: categoryTotals,
      totalSpend: totalSpend,
      dailyAverage: totalSpend / now.day,
      highestSpend: highestSpend,
      topCategory: categoryTotals.isEmpty
          ? null
          : categoryTotals.first.category,
    );
  }
}

class _CategoryTotal {
  const _CategoryTotal({required this.category, required this.total});

  final ExpenseCategoryOption category;
  final double total;

  double percentage(double totalSpend) {
    if (totalSpend <= 0) {
      return 0;
    }

    return total / totalSpend * 100;
  }
}
