import 'package:expense_tracker/core/constants/app_currency.dart';
import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/utils/expense_csv_exporter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expense_providers.dart';
import 'package:expense_tracker/features/settings/presentation/providers/currency_provider.dart';
import 'package:expense_tracker/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:expense_tracker/shared/widgets/page_body.dart';
import 'package:expense_tracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    final currency = ref.watch(currencyControllerProvider);

    return PageBody(
      slivers: [
        const SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Settings',
            subtitle: 'Keep the app comfortable for everyday use.',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your selection is saved on this device.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.devices_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) async {
                      await ref
                          .read(themeModeControllerProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: _CurrencyCard(
            selectedCurrency: currency,
            onCurrencyChanged: (currency) async {
              await ref
                  .read(currencyControllerProvider.notifier)
                  .setCurrency(currency);
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        const SliverToBoxAdapter(child: _DataManagementCard()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        const SliverToBoxAdapter(child: _SettingsList()),
      ],
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  final AppCurrency selectedCurrency;
  final ValueChanged<AppCurrency> onCurrencyChanged;

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
              'Currency',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose how amounts are displayed across the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final currency in AppCurrency.values)
                  ChoiceChip(
                    key: Key('currency-${currency.code.toLowerCase()}'),
                    avatar: Text(currency.symbol),
                    label: Text(currency.code),
                    selected: selectedCurrency == currency,
                    onSelected: (_) => onCurrencyChanged(currency),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataManagementCard extends ConsumerWidget {
  const _DataManagementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final expenseCount = expensesAsync.maybeWhen(
      data: (expenses) => expenses.length,
      orElse: () => 0,
    );
    final hasExpenses = expenseCount > 0;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup_table_rounded),
            title: const Text('Export CSV'),
            subtitle: Text(
              hasExpenses
                  ? 'Preview and copy $expenseCount expense records.'
                  : 'Add expenses first to export data.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            enabled: hasExpenses,
            onTap: hasExpenses ? () => _showCsvPreview(context, ref) : null,
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('clearAllExpensesButton'),
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear all expenses'),
            subtitle: Text(
              hasExpenses
                  ? 'Delete every saved expense from this device.'
                  : 'No expenses to clear.',
            ),
            enabled: hasExpenses,
            onTap: hasExpenses
                ? () => _confirmClearExpenses(context, ref)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showCsvPreview(BuildContext context, WidgetRef ref) async {
    final expenses = await ref.read(getExpensesUseCaseProvider).call();
    if (!context.mounted) {
      return;
    }

    final csv = ExpenseCsvExporter.export(expenses);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CsvPreviewSheet(csv: csv, expenses: expenses),
    );
  }

  Future<void> _confirmClearExpenses(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all expenses?'),
        content: const Text(
          'This permanently deletes every saved expense from local storage. Categories and settings will stay unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            key: const Key('confirmClearExpensesButton'),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear expenses'),
          ),
        ],
      ),
    );

    if (shouldClear != true) {
      return;
    }

    await ref.read(clearExpensesUseCaseProvider).call();
    ref.invalidate(expensesStreamProvider);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All expenses cleared successfully')),
    );
  }
}

class _CsvPreviewSheet extends StatelessWidget {
  const _CsvPreviewSheet({required this.csv, required this.expenses});

  final String csv;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          bottomPadding + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Expenses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${expenses.length} records ready as CSV.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SelectableText(
                    csv,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('copyExpenseCsvButton'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: csv));
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CSV copied to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy CSV'),
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

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.storage_rounded),
            title: Text('Local storage'),
            subtitle: Text('Hive stores expenses and categories offline.'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text('Categories'),
            subtitle: const Text('Manage spending categories.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.goNamed(AppRoutes.categoriesName),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: const [
        SizedBox(height: AppSpacing.md),
        Text(
          'A local-first personal expense tracker built with Flutter, Hive, Riverpod, and Material 3.',
        ),
      ],
    );
  }
}
