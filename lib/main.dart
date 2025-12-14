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

  // 1. Inisialisasi Hive
  await Hive.initFlutter();

  // 2. Registrasi Adapters (termasuk enum)
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());

  // 3. Buka Boxes
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');

  await Hive.openBox('user_prefs'); // <-- BUKA BOX INI

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

//testing testing
//testing 2 3 4 5