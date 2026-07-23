import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Add Expense',
            subtitle: 'The form workflow will be implemented in Phase 3.',
            trailing: IconButton.outlined(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        const SliverToBoxAdapter(child: _AddExpensePreviewForm()),
      ],
    );
  }
}

class _AddExpensePreviewForm extends StatelessWidget {
  const _AddExpensePreviewForm();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Date'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.schedule_rounded),
                    label: const Text('Time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
