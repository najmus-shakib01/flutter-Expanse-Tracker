import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditExpenseScreen extends ConsumerWidget {
  const EditExpenseScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseByIdProvider(expenseId));

    return expenseAsync.when(
      data: (expense) {
        if (expense == null) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Expense not found',
                  message: 'This transaction may have been removed.',
                ),
              ),
            ),
          );
        }

        return AddExpenseScreen(
          key: ValueKey('edit-expense-${expense.id}'),
          initialExpense: expense,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load expense',
              message: 'Please go back and try again.',
            ),
          ),
        ),
      ),
    );
  }
}
