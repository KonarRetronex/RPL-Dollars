import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/colors.dart';
import '../widgets/balance_card.dart'; // Widget ini akan kita ubah
import '../widgets/income_expense_card.dart'; // Widget ini akan kita ubah
import '../widgets/transaction_tile.dart'; // Widget ini akan kita ubah
import 'add_transaction_screen.dart'; // Untuk tombol 'Add Transaction'
// Kita tidak perlu chart lagi untuk desain ini
// import '../widgets/expense_chart.dart'; 
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello!'), // Sapaan baru
      ),
      body: Stack(
        children: [
          // 1. Latar Belakang Gradien
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4e348b), Color(0xFF2c2146)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Konten
          RefreshIndicator(
            onRefresh: () async {
              Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
              Provider.of<CategoryProvider>(context, listen: false).loadCategories();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Kartu Balance & Income/Expense (Layout baru)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Balance
                    Expanded(
                      flex: 2, // Ambil 2/3 ruang
                      child: BalanceCard(
                        balance: currencyFormatter.format(txProvider.totalBalance),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Kolom Kanan: Income & Expense
                    Expanded(
                      flex: 1, // Ambil 1/3 ruang
                      child: IncomeExpenseCard(
                        income: currencyFormatter.format(txProvider.totalIncome),
                        expense: currencyFormatter.format(txProvider.totalExpense),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Tombol Aksi (Baru)
                _buildActionButtons(context),
                const SizedBox(height: 24),

                // 3. Transaksi Terbaru
                Text(
                  'Recent Transaction',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                // 4. Daftar Transaksi
                txProvider.transactions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Belum ada transaksi.'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txProvider.transactions.length,
                        itemBuilder: (ctx, index) {
                          final tx = txProvider.transactions[index];
                          final category = catProvider.getCategoryById(tx.categoryId);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TransactionTile( // Widget ini akan kita update
                              transaction: tx,
                              category: category,
                              formatter: currencyFormatter,
                              onDelete: () {
                                txProvider.deleteTransaction(tx.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transaksi dihapus!')),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk tombol aksi
  Widget _buildActionButtons(BuildContext context) {
  return Row(
    // Kita gunakan crossAxisAlignment.start agar sejajar di atas
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Expanded( // <-- TAMBAHKAN WIDGET INI
        child: _ActionButton(
          icon: Icons.add,
          label: 'Add Transaction',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen()),
            );
          },
        ),
      ),
      Expanded( // <-- TAMBAHKAN WIDGET INI
        child: _ActionButton(
            icon: Icons.pie_chart, label: 'Monthly Budgeting', onTap: () {}),
      ),
      Expanded( // <-- TAMBAHKAN WIDGET INI
        child: _ActionButton(
            icon: Icons.account_balance_wallet, label: 'Multi-Wallet', onTap: () {}),
      ),
      Expanded( // <-- TAMBAHKAN WIDGET INI
        child: _ActionButton(
            icon: Icons.search, label: 'Searching', onTap: () {}),
      ),
    ],
  );
}
}

// Widget helper untuk UI tombol
// Widget helper untuk UI tombol
class _ActionButton extends StatelessWidget {
  // 1. DEKLARASIKAN PROPERTI DI SINI
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  // 2. TAMBAHKAN CONSTRUCTOR INI
  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Sekarang 'onTap' dikenali
      child: Column(
        children: [
          GlassCard(
            borderRadius: 50, // Lingkaran
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: Colors.white, size: 30), // 'icon' dikenali
          ),
          const SizedBox(height: 8),
          Text(
            label, // 'label' dikenali
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center, // <-- TAMBAHKAN INI
            maxLines: 2, // <-- TAMBAHKAN INI (Boleh 2 baris)
          ),
        ],
      ),
    );
  }
}