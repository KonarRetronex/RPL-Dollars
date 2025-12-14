import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/budget_model.dart';

class BudgetProvider with ChangeNotifier {
  late Box<BudgetModel> _budgetBox;

  List<BudgetModel> get budgets => _budgetBox.values.toList();

  BudgetProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    _budgetBox = await Hive.openBox<BudgetModel>('budgets');
    notifyListeners();
  }

  // Tambah Budget Baru
  Future<void> addBudget(BudgetModel budget) async {
    // Cek apakah budget untuk kategori ini di bulan ini sudah ada?
    final exists = _budgetBox.values.any((b) => 
      b.categoryId == budget.categoryId && 
      b.month == budget.month && 
      b.year == budget.year
    );

    if (exists) {
      // Jika sudah ada, kita update saja yang lama (opsional, atau tolak)
      // Disini kita biarkan user tahu atau hapus dulu yang lama
      return; 
    }

    await _budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  // Hapus Budget
  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
    notifyListeners();
  }
}