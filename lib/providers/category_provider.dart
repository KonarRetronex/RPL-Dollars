import 'package:flutter/material.dart'; // Impor untuk Icons
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class CategoryProvider with ChangeNotifier {
  final Box<CategoryModel> _categoryBox = Hive.box('categories');
  final Uuid _uuid = const Uuid();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  CategoryProvider() {
    loadCategories();
  }

  void loadCategories() {
    _categories = _categoryBox.values.toList().cast<CategoryModel>();
    if (_categories.isEmpty) {
      _addDefaultCategories();
    }
    notifyListeners();
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(id: _uuid.v4(), name: 'Salary', type: TransactionType.income, iconCodePoint: Icons.wallet_travel.codePoint),
      CategoryModel(id: _uuid.v4(), name: 'investment', type: TransactionType.income, iconCodePoint: Icons.insights.codePoint),
      CategoryModel(id: _uuid.v4(), name: 'Food', type: TransactionType.expense, iconCodePoint: Icons.restaurant.codePoint),
      //CategoryModel(id: _uuid.v4(), name: 'Transportation', type: TransactionType.expense, iconCodePoint: Icons.directions_bus.codePoint),
      CategoryModel(id: _uuid.v4(), name: 'Bill', type: TransactionType.expense, iconCodePoint: Icons.receipt_long.codePoint),
      CategoryModel(id: _uuid.v4(), name: 'Shopping', type: TransactionType.expense, iconCodePoint: Icons.shopping_bag.codePoint),
    ];

    for (var cat in defaultCategories) {
      await _categoryBox.put(cat.id, cat);
    }
    loadCategories();
  }
  
  // Perbarui fungsi ini
  Future<void> addCategory(String name, TransactionType type, int? iconCodePoint) async {
    final newCategory = CategoryModel(
      id: _uuid.v4(),
      name: name,
      type: type,
      iconCodePoint: iconCodePoint,
    );
    await _categoryBox.put(newCategory.id, newCategory);
    loadCategories();
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<void> deleteCategory(String id) async {
    // Perlu juga menghapus transaksi yang terkait jika diinginkan (opsional)
    await _categoryBox.delete(id);
    loadCategories();
  }

  CategoryModel getCategoryById(String id) {
    return _categories.firstWhere((cat) => cat.id == id,
        orElse: () => CategoryModel(id: 'default', name: 'Lainnya', type: TransactionType.expense, iconCodePoint: Icons.category.codePoint));
  }
  
  IconData getIconForCategory(String id) {
    final category = getCategoryById(id);
    if (category.iconCodePoint != null) {
      return IconData(category.iconCodePoint!, fontFamily: 'MaterialIcons');
    }
    return Icons.category; // Ikon default jika tidak ada
  }

  List<CategoryModel> get incomeCategories =>
      _categories.where((cat) => cat.type == TransactionType.income).toList();

  List<CategoryModel> get expenseCategories =>
      _categories.where((cat) => cat.type == TransactionType.expense).toList();
}