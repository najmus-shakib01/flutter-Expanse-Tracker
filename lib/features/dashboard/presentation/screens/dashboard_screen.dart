import 'package:expense_tracker/app/theme/app_colors.dart';
import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/extensions/date_time_formatting.dart';
import 'package:expense_tracker/features/categories/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_summary_card.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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
            title: 'Overview',
            subtitle: 'Live insight from your local expense history.',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        ...expensesAsync.when(
          data: (expenses) =>
              _buildDashboard(context, expenses, categories, currency),
          error: (error, stackTrace) => const [
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load dashboard',
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

  List<Widget> _buildDashboard(
    BuildContext context,
    List<Expense> expenses,
    List<ExpenseCategory> categories,
    AppCurrency currency,
  ) {
    final metrics = _DashboardMetrics.fromExpenses(expenses, categories);

    return [
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = width >= 900
              ? 4
              : width >= 560
              ? 2
              : 1;

          return SliverGrid(
            delegate: SliverChildListDelegate.fixed([
              DashboardSummaryCard(
                title: 'Monthly spend',
                value: currency.format(metrics.monthlySpend),
                icon: Icons.payments_outlined,
                color: AppColors.primary,
                caption: metrics.monthlyCount == 0
                    ? 'No spend this month'
                    : '${metrics.monthlyCount} this month',
              ),
              DashboardSummaryCard(
                title: 'Transactions',
                value: expenses.length.toString(),
                icon: Icons.receipt_long_outlined,
                color: AppColors.secondary,
                caption: expenses.isEmpty ? 'No entries yet' : 'All time',
              ),
              DashboardSummaryCard(
                title: 'Categories',
                value: categories.length.toString(),
                icon: Icons.category_outlined,
                color: AppColors.accent,
                caption: metrics.topCategoryName == null
                    ? 'Ready to organize'
                    : 'Top: ${metrics.topCategoryName}',
              ),
              DashboardSummaryCard(
                title: 'Daily average',
                value: currency.format(metrics.dailyAverage),
                icon: Icons.insights_outlined,
                color: AppColors.success,
                caption: 'Current month',
              ),
            ]),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 176,
            ),
          );
        },
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Monthly Snapshot',
          subtitle:
              '${_monthName(DateTime.now().month)} ${DateTime.now().year}',
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
      SliverToBoxAdapter(
        child: _MonthlySnapshotCard(metrics: metrics, currency: currency),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Recent Expenses',
          subtitle: metrics.recentExpenses.isEmpty
              ? 'Saved expenses will appear here.'
              : 'Latest ${metrics.recentExpenses.length} transactions.',
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
      if (metrics.recentExpenses.isEmpty)
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No recent expenses',
            message: 'Add your first expense to make the dashboard useful.',
            action: FilledButton.icon(
              onPressed: () => context.goNamed(AppRoutes.addExpenseName),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            ),
          ),
        )
      else
        SliverList.separated(
          itemCount: metrics.recentExpenses.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final expense = metrics.recentExpenses[index];
            final category = categoryOptionById(expense.categoryId, categories);

            return ExpensePreviewCard(
              title: expense.title,
              subtitle:
                  '${expense.spentAt.toShortDate()} - ${expense.categoryName}',
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
    ];
  }

  String _monthName(int month) {
    return switch (month) {
      1 => 'January',
      2 => 'February',
      3 => 'March',
      4 => 'April',
      5 => 'May',
      6 => 'June',
      7 => 'July',
      8 => 'August',
      9 => 'September',
      10 => 'October',
      11 => 'November',
      12 => 'December',
      _ => '',
    };
  }
}

class _MonthlySnapshotCard extends StatelessWidget {
  const _MonthlySnapshotCard({required this.metrics, required this.currency});

  final _DashboardMetrics metrics;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = metrics.monthlyProgress.clamp(0.0, 1.0);

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
                    'Monthly pace',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(progressValue * 100).round()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressValue),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              metrics.monthlyCount == 0
                  ? 'Add an expense this month to start seeing real trends.'
                  : '${currency.format(metrics.monthlySpend)} spent across ${metrics.monthlyCount} transactions this month.',
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

class _DashboardMetrics {
  const _DashboardMetrics({
    required this.monthlySpend,
    required this.monthlyCount,
    required this.dailyAverage,
    required this.monthlyProgress,
    required this.recentExpenses,
    this.topCategoryName,
  });

  final double monthlySpend;
  final int monthlyCount;
  final double dailyAverage;
  final double monthlyProgress;
  final List<Expense> recentExpenses;
  final String? topCategoryName;

  factory _DashboardMetrics.fromExpenses(
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

    final monthlySpend = monthlyExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final categoryTotals = <String, double>{};
    for (final expense in monthlyExpenses) {
      categoryTotals.update(
        expense.categoryId,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    String? topCategoryId;
    var topCategoryTotal = 0.0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > topCategoryTotal) {
        topCategoryId = entry.key;
        topCategoryTotal = entry.value;
      }
    }

    final sortedRecentExpenses = [...expenses]
      ..sort((first, second) => second.spentAt.compareTo(first.spentAt));

    return _DashboardMetrics(
      monthlySpend: monthlySpend,
      monthlyCount: monthlyExpenses.length,
      dailyAverage: monthlySpend / now.day,
      monthlyProgress: monthlySpend / 1000,
      recentExpenses: sortedRecentExpenses.take(4).toList(),
      topCategoryName: topCategoryId == null
          ? null
          : categoryOptionById(topCategoryId, categories).name,
    );
  }
}
