import 'package:expense_tracker/core/constants/app_routes.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/edit_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_details_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:expense_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:expense_tracker/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:expense_tracker/shared/widgets/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboardPath,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboardPath,
                name: AppRoutes.dashboardName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expensesPath,
                name: AppRoutes.expensesName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExpensesScreen()),
                routes: [
                  GoRoute(
                    path: AppRoutes.addExpenseSubPath,
                    name: AppRoutes.addExpenseName,
                    builder: (context, state) => const AddExpenseScreen(),
                  ),
                  GoRoute(
                    path: AppRoutes.editExpenseSubPath,
                    name: AppRoutes.editExpenseName,
                    builder: (context, state) {
                      final expenseId =
                          state.pathParameters[AppRoutes.expenseIdParam] ?? '';

                      return EditExpenseScreen(expenseId: expenseId);
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.expenseDetailsSubPath,
                    name: AppRoutes.expenseDetailsName,
                    builder: (context, state) {
                      final expenseId =
                          state.pathParameters[AppRoutes.expenseIdParam] ?? '';

                      return ExpenseDetailsScreen(expenseId: expenseId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.statisticsPath,
                name: AppRoutes.statisticsName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StatisticsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settingsPath,
                name: AppRoutes.settingsName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
              GoRoute(
                path: AppRoutes.categoriesPath,
                name: AppRoutes.categoriesName,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
