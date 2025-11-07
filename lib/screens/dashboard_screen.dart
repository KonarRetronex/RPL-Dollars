import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart'; // Widget ini akan kita ubah
import '../widgets/income_expense_card.dart'; // Widget ini akan kita ubah
import '../widgets/transaction_tile.dart'; // Widget ini akan kita ubah
import 'add_transaction_screen.dart'; // Untuk tombol 'Add Transaction'
// Kita tidak perlu chart lagi untuk desain ini
// import '../widgets/expense_chart.dart'; 
import '../widgets/glass_card.dart';
import '../utils/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

 @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Latar Belakang Gambar
          Container(
           decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Konten
          RefreshIndicator(
            onRefresh: () async {
              Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
              Provider.of<CategoryProvider>(context, listen: false).loadCategories();
            },
            
            // UBAH DARI 'ListView' MENJADI 'Padding' DAN 'Column'
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding tetap di luar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Agar 'Recent Transaction' rata kiri
                children: [
                  // 1. Kartu Balance & Income/Expense (STATIS)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kolom Kiri: Balance
                      Expanded(
                        flex: 2, 
                        child: BalanceCard(
                          balance: currencyFormatter.format(txProvider.totalBalance),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Kolom Kanan: Income & Expense
                      Expanded(
                        flex: 1,
                        child: IncomeExpenseCard(
                          income: currencyFormatter.format(txProvider.totalIncome),
                          expense: currencyFormatter.format(txProvider.totalExpense),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Tombol Aksi (STATIS)
                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  // 3. Transaksi Terbaru (STATIS)
                  Text(
                    'Recent Transaction',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  // 4. Daftar Transaksi (SCROLLABLE)
                  // 'Expanded' mengambil sisa ruang dan membuat child-nya bisa scroll
                  Expanded(
                    child: txProvider.transactions.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('There are no transactions yet.'),
                            ),
                          )
                        : ListView.builder(
                            // HAPUS shrinkWrap dan physics
                            itemCount: txProvider.transactions.length,
                            itemBuilder: (ctx, index) {
                              final tx = txProvider.transactions[index];
                              final category = catProvider.getCategoryById(tx.categoryId);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: TransactionTile( 
                                  transaction: tx,
                                  category: category,
                                  formatter: currencyFormatter,
                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Transaction'),
                                        content: Text('Are you sure want to delete this transaction "${category.name}"?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () => Navigator.of(ctx).pop(),
                                          ),
                                          TextButton(
                                            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
                                            onPressed: () {
                                              txProvider.deleteTransaction(tx.id);
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk tombol aksi
 Widget _buildActionButtons(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        // Tombol Add Transaction
        Expanded(
          child: _ActionButton(
            assetIconPath: 'assets/icons/bgicon.png',
            label: 'Add Transaction',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen()),
              );
            },
          ),
        ),
        
        // Tombol Monthly Budgeting
        Expanded(
          child: _ActionButton(
              assetIconPath: 'assets/icons/budgetting.png', label: 'Monthly Budgeting', onTap: () {}),
        ),
        
        // Tombol Multi-Wallet SUDAH DIHAPUS

        // Tombol Searching
        Expanded(
          child:
              _ActionButton(assetIconPath: 'assets/icons/search.png', label: 'Searching', onTap: () {}),
        ),
      ],
    );
  }
}

// Widget helper untuk UI tombol
// GANTI SELURUH CLASS LAMA ANDA DENGAN SEMUA KODE DI BAWAH INI

class _ActionButton extends StatefulWidget {
  final IconData? icon;
  final String? assetIconPath;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key, // Tambahkan Key
    this.icon,
    this.assetIconPath,
    required this.label,
    required this.onTap,
  })  : assert(icon != null || assetIconPath != null,
            'Either icon or assetIconPath must be provided'),
        super(key: key); // Tambahkan super(key: key)

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  // 1. State untuk melacak kondisi "ditekan"
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 2. Tentukan warna berdasarkan state
    final Color glassColor = _isPressed ? Colors.black : AppColors.glass;

    // 3. Logika untuk menentukan ikon (dari kode Anda)
    Widget iconWidget;
    if (widget.icon != null) { // Gunakan 'widget.icon'
      iconWidget = Icon(widget.icon, color: Colors.white, size: 30);
    } else {
      iconWidget = ImageIcon(
        AssetImage(widget.assetIconPath!), // Gunakan 'widget.assetIconPath'
        size: 30,
        color: const Color(0xFF6750A4), // Saya ganti ke putih agar cocok dengan tema
      );
    }

    // 4. Gunakan GestureDetector dengan state
    return GestureDetector(
      onTap: widget.onTap, // Gunakan 'widget.onTap'
      
      // Tambahkan logika untuk mengubah state saat ditekan/dilepas
      onTapDown: (details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      behavior: HitTestBehavior.translucent,
      
      child: Column(
        children: [
          GlassCard(
            color: glassColor, // 5. Terapkan warna dinamis di sini
            borderRadius: 50, // Lingkaran
            padding: const EdgeInsets.all(16),
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          Text(
            widget.label, // Gunakan 'widget.label'
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}