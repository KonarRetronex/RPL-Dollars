import 'package:flutter/material.dart';
import 'glass_card.dart'; // <-- Pastikan ini di-import
import '../utils/colors.dart'; // <-- Pastikan ini di-import

class BalanceCard extends StatelessWidget {
  final String balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    // 1. Ganti 'Container' menjadi 'GlassCard'
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24.0),

      // 2. Kita tetap butuh Container di DALAM-nya agar Spacer berfungsi
      child: SizedBox(
        // Beri tinggi yang pas agar sejajar dengan kartu Income/Expense
        height: 123, // Anda bisa sesuaikan angka ini
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks "Balance"
            Text(
              'Balance',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary, // <-- Ganti ke warna terang
                  ),
            ),
            
            const Spacer(), // Biarkan Spacer

            // Teks Saldo
            Center(
              child: Text(
                balance,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary, // <-- Ganti ke warna terang
                      fontSize: 28,
                    ),
              ),
            ),
            
            const Spacer(), // Biarkan Spacer
          ],
        ),
      ),
    );
  }
}