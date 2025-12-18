import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';
import 'providers/user_provider.dart';

import 'models/budget_model.dart'; // Import Model
import 'providers/budget_provider.dart'; // Import Provider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('MAIN: WidgetsFlutterBinding.ensureInitialized');

  // 1. Inisialisasi Hive
  try {
    print('MAIN: Hive.initFlutter() start');
    await Hive.initFlutter().timeout(const Duration(seconds: 10));
    print('MAIN: Hive.initFlutter() done');
  } catch (e, st) {
    print('MAIN: Hive.initFlutter() ERROR: $e\n$st');
  }

  // 2. Registrasi Adapters (termasuk enum)
  try {
    print('MAIN: Registering adapters');
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    print('MAIN: Adapters registered');
  } catch (e, st) {
    print('MAIN: Register adapters ERROR: $e\n$st');
  }

  // 3. Buka Boxes (each with timeout & error logging)
  Future<void> openBoxWithLog<T>(String name) async {
    try {
      print('MAIN: opening box $name');
      await Hive.openBox<T>(name).timeout(const Duration(seconds: 10));
      print('MAIN: opened box $name');
    } on TimeoutException catch (e) {
      print('MAIN: openBox $name TIMEOUT: $e');
    } catch (e, st) {
      print('MAIN: openBox $name ERROR: $e\n$st');
    }
  }

  await openBoxWithLog<TransactionModel>('transactions');
  await openBoxWithLog<CategoryModel>('categories');
  await openBoxWithLog('user_prefs');
  await openBoxWithLog<BudgetModel>('budgets');

  print('MAIN: finished init, calling runApp()');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Setup MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: 'Finance App',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(), // Terapkan tema custom kita
        home: const MainScreen(),
      ),
    );
  }
}

