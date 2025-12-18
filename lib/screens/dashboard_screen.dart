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
import 'monthly_budget_screen.dart'; // Untuk tombol 'Monthly Budgeting'
import 'package:rpl_fr/screens/search_screen.dart'; // Untuk tombol 'Searching'

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
          // 1. Background
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN INI KEMBALI SEPERTI SEMULA (TAPI ANTI-OVERFLOW) ---
                  SizedBox(
                    height: 140, // Tinggi tetap agar rapi
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // KIRI: Balance (Lebih Lebar - Flex 2)
                        Expanded(
                          flex: 2, 
                          child: BalanceCard(
                            balance: currencyFormatter.format(txProvider.totalBalance),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // KANAN: Income & Expense (Lebih Sempit - Flex 1)
                        // Disusun Vertikal (Atas/Bawah)
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // Kartu Income (Hijau)
                              _buildMiniCard(
                                title: "Income",
                                amount: currencyFormatter.format(txProvider.totalIncome),
                                icon: Icons.arrow_upward,
                                color: const Color(0xFF00D26A),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Kartu Expense (Merah)
                              _buildMiniCard(
                                title: "Expense",
                                amount: currencyFormatter.format(txProvider.totalExpense),
                                icon: Icons.arrow_downward,
                                color: const Color(0xFFFF2D2D),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // -----------------------------------------------------------

                  const SizedBox(height: 24),

                  // 2. Tombol Aksi
                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  // 3. Header Transaksi
                  Text(
                    'Recent Transaction',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  // 4. List Transaksi
                  Expanded(
                    child: txProvider.transactions.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('There are no transactions yet.'),
                            ),
                          )
                        : ListView.builder(
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
                                    // Logika hapus (kode asli Anda)
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Transaction'),
                                        content: Text('Delete "${category.name}"?'),
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

  // --- HELPER BARU: KARTU KECIL ANTI-OVERFLOW ---
  // Gunakan ini untuk menggantikan IncomeExpenseCard agar tidak error
  Widget _buildMiniCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderRadius: 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Icon Kecil + Judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 12),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    overflow: TextOverflow.ellipsis, // Potong teks judul jika kepanjangan
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Baris Bawah: Nominal Uang (Auto-Shrink)
            FittedBox(
              fit: BoxFit.scaleDown, // <--- KUNCI ANTI-OVERFLOW
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Sisa kode _buildActionButtons dan lainnya biarkan sama) ...

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
            assetIconPath: 'assets/icons/budgetting.png', 
            label: 'Monthly Budgeting', 
            onTap: () {
               // NAVIGASI KE SINI
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => const MonthlyBudgetScreen())
               );
            }
          ),
        ),
        
        // Tombol Multi-Wallet SUDAH DIHAPUS

        // Tombol Searching
        Expanded(
          child: _ActionButton(
            assetIconPath: 'assets/icons/search.png', // Sesuaikan path icon kamu
            label: 'Searching',
            onTap: () {
              // --- NAVIGASI KE SINI ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
              // ------------------------
            },
          ),
        ),
      ],
    );
  }
// Taruh fungsi ini di bagian paling bawah class DashboardScreen
  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded( // 1. Membagi lebar layar 50:50
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(6), 
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                
                // Judul (Income/Expense) dengan TextOverflow
                Expanded( // 2. Mencegah teks judul menabrak tepi kanan
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Nominal Uang dengan FittedBox
            FittedBox( // 3. Mengecilkan ukuran font otomatis jika angka panjang
              fit: BoxFit.scaleDown, 
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // <--- Ini kurung tutup terakhir class DashboardScreen Anda



// Widget helper untuk UI tombol
// GANTI SELURUH CLASS LAMA ANDA DENGAN SEMUA KODE DI BAWAH INI

class _ActionButton extends StatefulWidget {
  final IconData? icon;
  final String? assetIconPath;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    this.icon,
    this.assetIconPath,
    required this.label,
    required this.onTap,
  })  : assert(icon != null || assetIconPath != null,
            'Either icon or assetIconPath must be provided'); // Tambahkan super(key: key)

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

