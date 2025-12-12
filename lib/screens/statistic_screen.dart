import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  // Rentang tanggal default: Bulan Ini
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  // Fungsi pilih tanggal
  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  // ... (Fungsi _pickDateRange yang lama JANGAN DIUBAH) ...

  // --- FUNGSI BARU: PILIH BULAN ---
  void _pickMonth() {
    showDialog(
      context: context,
      builder: (context) {
        int year = _selectedDateRange.start.year; // Default tahun dari pilihan saat ini

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background.withOpacity(0.95), // Warna background ungu gelap
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Select Month", style: TextStyle(color: Colors.white)),
                  // Dropdown Tahun
                  DropdownButton<int>(
                    value: year,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    underline: Container(), // Hilangkan garis bawah
                    items: List.generate(10, (index) => 2020 + index).map((y) {
                      return DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => year = val); // Update tahun di dialog
                      }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final monthName = DateFormat('MMM').format(DateTime(year, index + 1));
                    return GestureDetector(
                      onTap: () {
                        // Set range dari tanggal 1 sampai akhir bulan tersebut
                        final start = DateTime(year, index + 1, 1);
                        // Trik: hari ke-0 bulan depan adalah hari terakhir bulan ini
                        final end = DateTime(year, index + 2, 0); 
                        
                        setState(() {
                          _selectedDateRange = DateTimeRange(start: start, end: end);
                        });
                        Navigator.pop(context); // Tutup dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          monthName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    final txProvider = Provider.of<TransactionProvider>(context);

    // 1. Filter Data Berdasarkan Tanggal
    final List<TransactionModel> filteredTransactions = txProvider.transactions.where((tx) {
      return tx.date.isAfter(_selectedDateRange.start.subtract(const Duration(days: 1))) &&
             tx.date.isBefore(_selectedDateRange.end.add(const Duration(days: 1)));
    }).toList();

    // 2. Hitung Total Income & Expense
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in filteredTransactions) {
      if (tx.type == TransactionType.income) totalIncome += tx.amount;
      if (tx.type == TransactionType.expense) totalExpense += tx.amount;
    }
    double totalBalance = totalIncome - totalExpense;

    return Stack(
      children: [
        // Background Image
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
            title: const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context), // Tombol kembali
            ),
            actions: [
              // 1. TOMBOL BARU (Pilih Bulan Cepat)
              IconButton(
                icon: const Icon(Icons.calendar_view_month), // Ikon kotak-kotak bulan
                tooltip: "Select Month",
                onPressed: _pickMonth, // Panggil fungsi baru
              ),
              
              // 2. TOMBOL LAMA (Range Bebas - TETAP ADA)
              IconButton(
                icon: const Icon(Icons.date_range), // Ikon kalender range
                tooltip: "Custom Range",
                onPressed: _pickDateRange, // Panggil fungsi lama
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Judul Chart Baru
                const Text(
                  "Income vs Expense", // <-- Judul Baru
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 2. BAR CHART (Grafik Batang)
                SizedBox(
                  height: 300, // Sedikit lebih tinggi agar label muat
                  child: _buildBarChart(filteredTransactions),
                ),
                const SizedBox(height: 25),

                // 3. FINANCIAL SUMMARY (Judul)
                const Text(
                  "Financial Summary",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 4. KARTU SUMMARY
                Row(
                  children: [
                    Expanded(child: _SummaryPill(title: "Income", amount: totalIncome)),
                    const SizedBox(width: 10),
                    Expanded(child: _SummaryPill(title: "Expense", amount: totalExpense)),
                    const SizedBox(width: 10),
                    Expanded(child: _SummaryPill(title: "Balance", amount: totalBalance)),
                  ],
                ),
                const SizedBox(height: 30),

                // 5. PIE CHART (Judul)
                const Text(
                  "Analysis of expenses and income",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // 6. PIE CHART
                if (totalIncome > 0 || totalExpense > 0)
                  _buildPieChart(totalIncome, totalExpense)
                else
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No data available", style: TextStyle(color: Colors.white54)),
                  )),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET CHART YANG DIPERBARUI ---

  Widget _buildBarChart(List<TransactionModel> transactions) {
    // 1. Kelompokkan data per hari
    Map<int, double> incomeMap = {};
    Map<int, double> expenseMap = {};
    
    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        incomeMap[tx.date.day] = (incomeMap[tx.date.day] ?? 0) + tx.amount;
      } else {
        expenseMap[tx.date.day] = (expenseMap[tx.date.day] ?? 0) + tx.amount;
      }
    }
    
    // 2. Cari nilai tertinggi (Max Y) agar grafik tidak kepotong
    double maxY = 0;
    incomeMap.forEach((k, v) => maxY = v > maxY ? v : maxY);
    expenseMap.forEach((k, v) => maxY = v > maxY ? v : maxY);
    if (maxY == 0) maxY = 1000; // Default jika kosong

    // 3. Pastikan sumbu X mencakup semua hari dalam range yang dipilih (opsional, atau hanya hari yang ada transaksi)
    // Disini kita urutkan hari yang ada transaksinya saja agar rapi
    List<int> days = {...incomeMap.keys, ...expenseMap.keys}.toList()..sort();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2, // Kasih ruang 20% di atas
        
        // Atur Grid (Garis tipis di belakang)
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        
        borderData: FlBorderData(show: false),
        
        // Atur Judul Sumbu (X dan Y)
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // Sumbu Kiri (Y-Axis) - Nominal Uang
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Ruang untuk teks angka
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                // Format angka: 1.5M, 500k, dsb
                return Text(
                  NumberFormat.compact(locale: 'id_ID').format(value),
                  style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          
          // Sumbu Bawah (X-Axis) - Tanggal
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Tampilkan angka tanggal
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Data Batang
        barGroups: days.map((day) {
          return BarChartGroupData(
            x: day,
            barRods: [
              // Batang Hijau (Income)
              if (incomeMap.containsKey(day))
                BarChartRodData(
                  toY: incomeMap[day]!, 
                  color: const Color(0xFF00D26A), // Hijau Neon
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2, // Latar belakang transparan penuh
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              // Batang Merah (Expense)
              if (expenseMap.containsKey(day))
                BarChartRodData(
                  toY: expenseMap[day]!, 
                  color: const Color(0xFFFF2D2D), // Merah
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(double income, double expense) {
    double total = income + expense;
    double incomePercent = total == 0 ? 0 : (income / total) * 100;
    double expensePercent = total == 0 ? 0 : (expense / total) * 100;

    return Row(
      children: [
        // PIE CHART
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0, 
              startDegreeOffset: -90,
              sections: [
                if (income > 0)
                PieChartSectionData(
                  color: const Color(0xFF00D26A), // Hijau
                  value: income,
                  title: '${incomePercent.toStringAsFixed(0)}%',
                  radius: 90,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if (expense > 0)
                PieChartSectionData(
                  color: const Color(0xFFFF2D2D), // Merah
                  value: expense,
                  title: '${expensePercent.toStringAsFixed(0)}%',
                  radius: 90,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        // LEGEND (Keterangan)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: const Color(0xFF00D26A), label: 'Income'),
              const SizedBox(height: 15),
              _LegendItem(color: const Color(0xFFFF2D2D), label: 'Expense'),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget Kartu Ringkasan (Pill Shape)
class _SummaryPill extends StatelessWidget {
  final String title;
  final double amount;

  const _SummaryPill({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.white.withOpacity(0.15), // Transparan ungu muda
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(amount),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget Legend
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}