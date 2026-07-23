import 'package:expense_tracker/app/theme/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_summary_card.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      slivers: [
        const SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Overview',
            subtitle: 'Track spending, categories, and monthly progress.',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final crossAxisCount = width >= 900
                ? 4
                : width >= 560
                ? 2
                : 1;

            return SliverGrid(
              delegate: SliverChildListDelegate.fixed(const [
                DashboardSummaryCard(
                  title: 'Monthly spend',
                  value: r'$0.00',
                  icon: Icons.payments_outlined,
                  color: AppColors.primary,
                  caption: 'No expenses yet',
                ),
                DashboardSummaryCard(
                  title: 'Transactions',
                  value: '0',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.secondary,
                  caption: 'Ready for local storage',
                ),
                DashboardSummaryCard(
                  title: 'Categories',
                  value: '0',
                  icon: Icons.category_outlined,
                  color: AppColors.accent,
                  caption: 'Coming in category setup',
                ),
                DashboardSummaryCard(
                  title: 'Budget health',
                  value: 'Good',
                  icon: Icons.verified_outlined,
                  color: AppColors.success,
                  caption: 'Waiting for real data',
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
        const SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Monthly Snapshot',
            subtitle: 'A clean space for summaries once expenses are saved.',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        const SliverToBoxAdapter(child: _MonthlySnapshotCard()),
      ],
    );
  }
}

class _MonthlySnapshotCard extends StatelessWidget {
  const _MonthlySnapshotCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'July progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first expense to start calculating monthly insights.',
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
