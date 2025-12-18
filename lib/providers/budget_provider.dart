import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/budget_model.dart';

class BudgetProvider with ChangeNotifier {
  Box<BudgetModel>? _budgetBox;

  // Getter: Ambil data, return kosong jika box belum siap
  List<BudgetModel> get budgets {
    if (_budgetBox == null || !_budgetBox!.isOpen) {
      return [];
    }
    return _budgetBox!.values.toList();
  }

  BudgetProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    // Pastikan box terbuka
    if (Hive.isBoxOpen('budgets')) {
      _budgetBox = Hive.box<BudgetModel>('budgets');
    } else {
      _budgetBox = await Hive.openBox<BudgetModel>('budgets');
    }
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel budget) async {
    // 1. Cek Box
    if (_budgetBox == null || !_budgetBox!.isOpen) {
      await _initBox();
    }
    
    // Jika masih gagal buka, lempar error
    if (_budgetBox == null || !_budgetBox!.isOpen) {
      throw "Database Error: Box 'budgets' cannot be opened.";
    }

    try {
      dynamic existingKey;

      // 2. Cek apakah Budget untuk Kategori & Bulan ini sudah ada?
      // Kita loop manual (lebih aman daripada firstWhere)
      for (var key in _budgetBox!.keys) {
        final b = _budgetBox!.get(key);
        // Pastikan b tidak null sebelum cek properti
        if (b != null && 
            b.categoryId == budget.categoryId && 
            b.month == budget.month && 
            b.year == budget.year) {
          existingKey = key; // Ketemu data lama!
          break; 
        }
      }

      if (existingKey != null) {
        // UPDATE: Timpa data lama dengan data baru
        print("LOG: Update Budget Lama (Key: $existingKey)");
        await _budgetBox!.put(existingKey, budget); 
      } else {
        // BARU: Simpan data baru
        print("LOG: Simpan Budget Baru (ID: ${budget.id})");
        await _budgetBox!.put(budget.id, budget);
      }
      
      notifyListeners(); // Update UI
      print("LOG: SUKSES SAVE!");

    } catch (e) {
      print("LOG: ERROR DI PROVIDER: $e");
      rethrow; // <--- INI PENTING: Lempar error ke UI agar muncul SnackBar Merah
    }
  }

  Future<void> deleteBudget(String id) async {
    if (_budgetBox != null && _budgetBox!.isOpen) {
      await _budgetBox!.delete(id);
      notifyListeners();
    }
  }
}