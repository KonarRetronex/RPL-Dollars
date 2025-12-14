import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';

class MonthlyBudgetScreen extends StatefulWidget {
  const MonthlyBudgetScreen({super.key});

  @override
  State<MonthlyBudgetScreen> createState() => _MonthlyBudgetScreenState();
}

class _MonthlyBudgetScreenState extends State<MonthlyBudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _pickMonth() async {
    // Simple month picker: Show dialog to pick year and month
    // Untuk simplifikasi, kita pakai YearPicker lalu pilih bulan, atau UI custom sederhana
    // Di sini saya buat geser bulan sederhana (Prev/Next)
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);

    // Filter budget sesuai bulan yang dipilih
    final currentBudgets = budgetProvider.budgets.where((b) => 
      b.month == _selectedMonth.month && b.year == _selectedMonth.year
    ).toList();

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Monthly Budgeting"),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // 1. Selector Bulan (Simple Prev/Next)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 2. List Budget
              Expanded(
                child: currentBudgets.isEmpty
                    ? const Center(child: Text("No budget set for this month", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentBudgets.length,
                        itemBuilder: (context, index) {
                          final budget = currentBudgets[index];
                          final category = catProvider.getCategoryById(budget.categoryId);
                          
                          // HITUNG PROGRESS
                          // Ambil transaksi expense untuk kategori ini di bulan ini
                          final expenses = txProvider.transactions.where((tx) =>
                            tx.categoryId == budget.categoryId &&
                            tx.type == TransactionType.expense &&
                            tx.date.month == budget.month &&
                            tx.date.year == budget.year
                          ).toList();
                          
                          double totalUsed = expenses.fold(0, (sum, item) => sum + item.amount);
                          double progress = totalUsed / budget.limitAmount;
                          if (progress > 1.0) progress = 1.0;

                          return _BudgetCard(
                            category: category,
                            budget: budget,
                            usedAmount: totalUsed,
                            progress: progress,
                            onDelete: () => budgetProvider.deleteBudget(budget.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          
          // 3. Tombol Tambah Budget
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddBudgetDialog(context, catProvider, budgetProvider),
            label: const Text("Set Budget", style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showAddBudgetDialog(BuildContext context, CategoryProvider catProvider, BudgetProvider budgetProvider) {
    final amountController = TextEditingController();
    CategoryModel? selectedCategory;
    
    // Default ambil kategori expense pertama jika ada
    if (catProvider.expenseCategories.isNotEmpty) {
      selectedCategory = catProvider.expenseCategories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2146),
              title: const Text("Set Monthly Budget", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pilih Kategori
                  DropdownButton<CategoryModel>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF2C2146),
                    isExpanded: true,
                    hint: const Text("Select Category", style: TextStyle(color: Colors.white54)),
                    items: catProvider.expenseCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(IconData(cat.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'), color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(cat.name, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 16),
                  
                  // Input Nominal
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Limit Amount (Rp)",
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (selectedCategory != null && amountController.text.isNotEmpty) {
                      final newBudget = BudgetModel(
                        id: const Uuid().v4(),
                        categoryId: selectedCategory!.id,
                        limitAmount: double.parse(amountController.text),
                        month: _selectedMonth.month,
                        year: _selectedMonth.year,
                      );
                      budgetProvider.addBudget(newBudget);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }
}

// WIDGET KARTU BUDGET (Progress Bar)
class _BudgetCard extends StatelessWidget {
  final CategoryModel category;
  final BudgetModel budget;
  final double usedAmount;
  final double progress;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.category,
    required this.budget,
    required this.usedAmount,
    required this.progress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Warna Progress Bar: Hijau jika aman, Merah jika > 80%
    Color progressColor = const Color(0xFF00D26A); // Hijau
    if (progress >= 1.0) {
      progressColor = const Color(0xFFFF2D2D); // Merah (Over budget)
    } else if (progress > 0.8) {
      progressColor = Colors.orange; // Warning
    }

    final percent = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    IconData(category.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        "${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(usedAmount)} / ${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(budget.limitAmount)}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                // Percentage Text
                Text(
                  "$percent%",
                  style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                
                // Delete Button
                IconButton(
                   icon: const Icon(Icons.delete_outline, color: Colors.white30, size: 20),
                   onPressed: onDelete,
                )
              ],
            ),
            const SizedBox(height: 12),
            
            // PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}