import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/colors.dart';
import 'glass_card.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel category;
  final NumberFormat formatter;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.formatter,
    required this.onDelete,
  });

@override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final sign = isIncome ? '+' : '-';
    
    // GANTI LOGIKA IKON LAMA DENGAN INI:
    final IconData iconData = IconData(
        category.iconCodePoint ?? Icons.category.codePoint, // Ambil dari model
        fontFamily: 'MaterialIcons');

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.glass.withOpacity(0.2),
          child: Icon(iconData, color: Colors.white, size: 24),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        subtitle: Column( // <-- GANTI MENJADI COLUMN
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tampilkan Catatan (jika ada)
            if (transaction.note.isNotEmpty) // Cek apakah catatan tidak kosong
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0), // Beri jarak sedikit
                child: Text(
                  transaction.note,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontStyle: FontStyle.normal, // Buat miring agar beda
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            // 2. Tampilkan Tanggal
            Text(
              DateFormat('E, dd/MM/yyyy').format(transaction.date), // Format tanggal
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign ${formatter.format(transaction.amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            // Tombol delete (mungkin di-hide agar UI lebih bersih, 
            // atau ganti dengan gestur 'onLongPress' pada GlassCard)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}