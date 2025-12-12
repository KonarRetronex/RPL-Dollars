import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import '../utils/colors.dart';

class CategoryDetailScreen extends StatelessWidget {
  // 1. Screen ini menerima data kategori
  final CategoryModel category;
  
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Kita butuh formatter untuk TransactionTile
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Stack(
      children: [
        // 2. Latar belakang gambar
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

        // 3. Scaffold transparan
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(category.name), // Judulnya adalah nama kategori
          ),
          body: Consumer<TransactionProvider>(
            builder: (context, txProvider, child) {
              
              // 4. Logika filter transaksi
              final List<TransactionModel> filteredTransactions = txProvider.transactions
                  .where((tx) => tx.categoryId == category.id)
                  .toList();
              
              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Text(
                    'There is no transaction on this category yet.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              }

              // 5. Tampilkan daftar transaksi yang sudah difilter
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = filteredTransactions[index];
                  
                  // Kita gunakan lagi TransactionTile yang sudah ada
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TransactionTile(
                      transaction: tx,
                      category: category, // Kategorinya sama untuk semua item
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
              );
            },
          ),
        ),
      ],
    );
  }
}