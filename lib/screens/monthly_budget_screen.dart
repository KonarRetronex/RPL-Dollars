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

  void _pickMonth() {
    showDialog(
      context: context,
      builder: (context) {
        int year = _selectedMonth.year;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2146),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Month", style: TextStyle(color: Colors.white, fontSize: 16)),
                  DropdownButton<int>(
                    value: year,
                    dropdownColor: const Color(0xFF2C2146),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: List.generate(11, (index) => 2020 + index).map((y) {
                      return DropdownMenuItem(value: y, child: Text(y.toString()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => year = val);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = year == _selectedMonth.year && (index + 1) == _selectedMonth.month;
                    final monthName = DateFormat('MMM').format(DateTime(year, index + 1));
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = DateTime(year, index + 1);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          monthName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
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
              // 1. Selector Bulan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: _pickMonth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_selectedMonth),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
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
                          
                          // Hitung Logika Bar
                          final expenses = txProvider.transactions.where((tx) =>
                            tx.categoryId == budget.categoryId &&
                            tx.type == TransactionType.expense &&
                            tx.date.month == budget.month &&
                            tx.date.year == budget.year
                          ).toList();
                          
                          double totalUsed = expenses.fold(0, (sum, item) => sum + item.amount);
                          
                          double spentRatio = totalUsed / budget.limitAmount;
                          if (spentRatio > 1.0) spentRatio = 1.0; 
                          
                          double remainingRatio = 1.0 - spentRatio;
                          if (remainingRatio < 0) remainingRatio = 0.0;

                          return _BudgetCard(
                            category: category,
                            budget: budget,
                            usedAmount: totalUsed,
                            spentRatio: spentRatio,        
                            remainingRatio: remainingRatio, 
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
    double warningPercent = 0.20; // Default warning level

    if (catProvider.expenseCategories.isNotEmpty) {
      selectedCategory = catProvider.expenseCategories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        // Ambil TransactionProvider untuk cek saldo saat save
        final txProvider = Provider.of<TransactionProvider>(context, listen: false);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2146),
              title: const Text("Set Monthly Budget", style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Category", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    DropdownButton<CategoryModel>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF2C2146),
                      isExpanded: true,
                      underline: Container(height: 1, color: Colors.white24),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
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
                    const SizedBox(height: 24),
                    
                    // --- SLIDER NOTIFIKASI ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Warning Notification", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text(
                          "at ${(warningPercent * 100).toInt()}% left",
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: warningPercent,
                      min: 0.05,
                      max: 0.95,
                      divisions: 18,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white10,
                      label: "${(warningPercent * 100).toInt()}%",
                      onChanged: (val) {
                        setState(() => warningPercent = val);
                      },
                    ),
                    const Text(
                      "Alert will appear when the green bar drops below this percentage.",
                      style: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (selectedCategory != null && amountController.text.isNotEmpty) {
                      try {
                        String cleanAmount = amountController.text.replaceAll('.', '').replaceAll(',', '');
                        final double amount = double.parse(cleanAmount);

                        final newBudget = BudgetModel(
                          id: const Uuid().v4(),
                          categoryId: selectedCategory!.id,
                          limitAmount: amount,
                          month: _selectedMonth.month,
                          year: _selectedMonth.year,
                          warningPercentage: warningPercent,
                        );

                        await budgetProvider.addBudget(newBudget);

                        // --- LOGIKA DETEKTIF: CEK APAKAH SUDAH BAHAYA? ---
                        
                        final currentExpenses = txProvider.transactions.where((tx) =>
                          tx.categoryId == selectedCategory!.id &&
                          tx.type == TransactionType.expense &&
                          tx.date.month == _selectedMonth.month &&
                          tx.date.year == _selectedMonth.year
                        ).toList();

                        double used = currentExpenses.fold(0, (sum, item) => sum + item.amount);
                        double ratioUsed = used / amount;
                        double ratioLeft = 1.0 - ratioUsed;

                        if (context.mounted) {
                          Navigator.pop(context); // Tutup Dialog

                          if (ratioLeft <= warningPercent) {
                            // BAHAYA
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Warning! Sisa budget tinggal ${(ratioLeft * 100).toStringAsFixed(0)}%. Hemat ya!",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.deepOrange,
                                duration: const Duration(seconds: 4),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            // AMAN
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Budget saved successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red),
                          );
                        }
                      }
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
} // <--- KURUNG TUTUP INI YANG TADI HILANG!

// --- WIDGET BUDGET CARD ---
class _BudgetCard extends StatelessWidget {
  final CategoryModel category;
  final BudgetModel budget;
  final double usedAmount;
  final double spentRatio;
  final double remainingRatio;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.category,
    required this.budget,
    required this.usedAmount,
    required this.spentRatio,
    required this.remainingRatio,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = (remainingRatio * 100).toInt();
    
    // LOGIKA WARNA DINAMIS
    bool isDanger = remainingRatio <= budget.warningPercentage;
    Color textColor = isDanger ? const Color(0xFFFF2D2D) : const Color(0xFF00D26A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          if (isDanger) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF2D2D), size: 18),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(usedAmount)} / ${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(budget.limitAmount)}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$percentText%",
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (isDanger)
                      Text("Low Budget!", style: TextStyle(color: textColor, fontSize: 10)),
                  ],
                ),
                IconButton(
                   icon: const Icon(Icons.delete_outline, color: Colors.white30, size: 20),
                   onPressed: onDelete,
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    if (remainingRatio > 0)
                      Expanded(
                        flex: (remainingRatio * 100).toInt(),
                        child: Container(color: const Color(0xFF00D26A)),
                      ),
                    if (spentRatio > 0)
                      Expanded(
                        flex: (spentRatio * 100).toInt(),
                        child: Container(color: const Color(0xFFFF2D2D)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}