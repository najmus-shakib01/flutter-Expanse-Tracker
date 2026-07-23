import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Expenses',
            subtitle: 'Your transactions will appear here.',
            trailing: IconButton.filledTonal(
              tooltip: 'Search',
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No expenses recorded',
            message:
                'Once local storage is connected, saved expenses will be listed by date.',
            action: FilledButton.icon(
              onPressed: () => context.goNamed(AppRoutes.addExpenseName),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            ),
          ),
        ),
      ],
    );
  }
}
