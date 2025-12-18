import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// GUNAKAN ABSOLUTE IMPORT (Sesuai perbaikan sebelumnya)
import 'package:rpl_fr/models/transaction_model.dart';
import 'package:rpl_fr/providers/transaction_provider.dart';
import 'package:rpl_fr/providers/category_provider.dart';
import 'package:rpl_fr/utils/colors.dart';
import 'package:rpl_fr/widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);

    // LOGIKA PENCARIAN
    final List<TransactionModel> searchResults = txProvider.transactions.where((tx) {
      if (_query.isEmpty) {
        return false;
      }

      final category = catProvider.getCategoryById(tx.categoryId);
      final queryLower = _query.toLowerCase();

      final matchNote = tx.note.toLowerCase().contains(queryLower);
      final matchCategory = category.name.toLowerCase().contains(queryLower);
      final matchAmount = tx.amount.toInt().toString().contains(queryLower);
      final dateString = DateFormat('dd MMMM yyyy').format(tx.date).toLowerCase();
      final matchDate = dateString.contains(queryLower);

      return matchNote || matchCategory || matchAmount || matchDate;
    }).toList();

    // Sort: Terbaru ke Terlama
    searchResults.sort((a, b) => b.date.compareTo(a.date));

    return Stack(
      children: [
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          body: _query.isEmpty
              ? _buildEmptyState()
              : searchResults.isEmpty
                  ? _buildNoResultState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final tx = searchResults[index];
                        final category = catProvider.getCategoryById(tx.categoryId);
                        return _buildResultItem(tx, category);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("Find transactions", style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildNoResultState() {
    return Center(
      child: Text("No result found", style: TextStyle(color: Colors.white.withOpacity(0.5))),
    );
  }

  Widget _buildResultItem(TransactionModel tx, var category) {
    final isExpense = tx.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF2D2D) : const Color(0xFF00D26A);
    final iconData = IconData(category.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons');

    // FORMAT TANGGAL (Agar mirip dashboard)
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(tx.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(iconData, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  
                  // Tampilkan NOTE (Jika ada)
                  if (tx.note.isNotEmpty)
                    Text(tx.note, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  
                  // Tampilkan TANGGAL (Tambahan Baru)
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              "${isExpense ? '-' : '+'} ${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(tx.amount)}",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}