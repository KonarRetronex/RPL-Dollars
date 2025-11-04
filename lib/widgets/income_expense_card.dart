import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'glass_card.dart';

class IncomeExpenseCard extends StatelessWidget {
  final String income;
  final String expense;

  const IncomeExpenseCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: _buildCard(
            context,
            'Income',
            income,
            AppColors.income,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: _buildCard(
            context,
            'Expense',
            expense,
            AppColors.expense,
            Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

// Di dalam file: lib/widgets/income_expense_card.dart

Widget _buildCard(
  BuildContext context,
  String title,
  String amount,
  Color color,
  IconData icon,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 12,
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded( // <-- TAMBAHKAN INI
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium,
              overflow: TextOverflow.ellipsis, // Jaga-jaga jika judul terlalu panjang
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Flexible( // <-- TAMBAHKAN INI
        child: Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
          // Hapus overflow & maxLines agar bisa wrap
        ),
      ),
    ],
  );
}
}