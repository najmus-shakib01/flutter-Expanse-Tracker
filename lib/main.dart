import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/preferences/app_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.initialize();
  await AppDatabase.initialize();

  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}
