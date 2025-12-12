import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart'; // Untuk GlassCard
import 'package:uuid/uuid.dart'; // <-- TAMBAHKAN BARIS INI

// Widget helper untuk tombol kategori kecil di bawah
class _SmallCategoryButton extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool isSelected;

  const _SmallCategoryButton({
    required this.category,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard( // Menggunakan GlassCard
        borderRadius: 15, // Sedikit membulat
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected ? const Color.fromARGB(255, 73, 59, 116) : AppColors.glass, // Warna berubah saat dipilih
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(category.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
              color: isSelected ? Colors.white : AppColors.textPrimary, // Warna ikon
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary, // Warna teks
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;
  final _noteController = TextEditingController();

  String _currentAmount = '0'; // Untuk tampilan angka kalkulator

  @override
  void initState() {
    super.initState();
    // Inisialisasi kategori default (misal: "Lainnya" untuk expense/income)
    _setDefaultCategory();
  }

  void _setDefaultCategory() {
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (_selectedType == TransactionType.expense && catProvider.expenseCategories.isNotEmpty) {
      _selectedCategory = catProvider.expenseCategories.first;
    } else if (_selectedType == TransactionType.income && catProvider.incomeCategories.isNotEmpty) {
      _selectedCategory = catProvider.incomeCategories.first;
    }
  }

  void _updateAmount(String value) {
    setState(() {
      if (value == '000') {
        if (_currentAmount == '0') {
          _currentAmount = '0';
        } else {
          _currentAmount += '000';
        }
      } else if (value == 'clear') { // Tombol panah kanan untuk hapus satu digit
        if (_currentAmount.length > 1) {
          _currentAmount = _currentAmount.substring(0, _currentAmount.length - 1);
        } else {
          _currentAmount = '0';
        }
      } else {
        if (_currentAmount == '0') {
          _currentAmount = value;
        } else {
          _currentAmount += value;
        }
      }
      // Batasi panjang angka jika terlalu panjang
      if (_currentAmount.length > 10) {
        _currentAmount = _currentAmount.substring(0, 10);
      }
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary, // Warna highlight
              onPrimary: Colors.white,
              surface: AppColors.background, // Warna background picker
              onSurface: AppColors.textPrimary, // Warna teks
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary, // Warna tombol Batal/OK
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.background.withOpacity(0.8)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTransaction() {
    final amount = double.tryParse(_currentAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori.')),
      );
      return;
    }

    final newTransaction = TransactionModel(
      id: const Uuid().v4(),
      title: _selectedCategory!.name, // Atau bisa juga menggunakan note jika ada
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      categoryId: _selectedCategory!.id,
      note: _noteController.text, // Simpan catatan
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
    );

    // Reset state
    setState(() {
      _currentAmount = '0';
      _selectedDate = DateTime.now();
      _noteController.clear();
      _setDefaultCategory(); // Reset kategori ke default
    });
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CategoryProvider>(context);

    // Filter kategori berdasarkan jenis transaksi yang dipilih
    final List<CategoryModel> displayedCategories =
        _selectedType == TransactionType.expense
            ? catProvider.expenseCategories
            : catProvider.incomeCategories;
            
    // Pastikan _selectedCategory selalu ada di daftar yang ditampilkan
    if (_selectedCategory != null && 
        !displayedCategories.any((cat) => cat.id == _selectedCategory!.id)) {
      _selectedCategory = displayedCategories.isNotEmpty ? displayedCategories.first : null;
    } else if (_selectedCategory == null && displayedCategories.isNotEmpty) {
      _selectedCategory = displayedCategories.first;
    }


    return Stack(
      children: [
        // 1. Latar Belakang Gambar
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
            title: const Text('Add Transaction'),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView( // Agar bisa di-scroll jika keyboard muncul
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 1. Tombol Income/Expense (Segmented Control)
                      GlassCard( // Dibungkus GlassCard
                    
                        borderRadius: 20,
                        padding: const EdgeInsets.all(4.0), // Padding kecil agar tombol pas
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _TransactionTypeButton(
                                label: 'Income',
                                type: TransactionType.income,
                                isSelected: _selectedType == TransactionType.income,
                                onTap: () {
                                  setState(() {
                                    _selectedType = TransactionType.income;
                                    _setDefaultCategory(); // Set kategori default yang sesuai
                                  });
                                },
                                backgroundColor: AppColors.income,
                              ),
                            ),
                            Expanded(
                              child: _TransactionTypeButton(
                                label: 'Expense',
                                type: TransactionType.expense,
                                isSelected: _selectedType == TransactionType.expense,
                                onTap: () {
                                  setState(() {
                                    _selectedType = TransactionType.expense;
                                    _setDefaultCategory(); // Set kategori default yang sesuai
                                  });
                                },
                                backgroundColor: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Input Nominal & Tanggal
                      // Container(
                      
                      //   padding: const EdgeInsets.all(16.0),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white70,
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),

                        // child: Column(
                        //   children: [
                            // 2. TANGGAL (Tanpa border)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, // <-- Buat tanggal rata tengah
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.calendar_month, color: AppColors.textSecondary, size: 28),
                                  onPressed: () => _selectDate(context),
                                  highlightColor: AppColors.primary.withOpacity(0.3),
                                  splashColor: AppColors.primary.withOpacity(0.2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.textSecondary, // Sesuaikan warna jika perlu
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16), // Jarak antara tanggal and lingkaran

                            // 3. NOMINAL (Bentuk Lingkaran)
                            GlassCard(
                              borderRadius: 30, // <-- Angka besar untuk lingkaran sempurna
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox( // <-- Beri ukuran tetap untuk lingkaran
                                width: 320,
                                height: 144,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Tombol Naikkan Nominal (sesuai desain)
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_up, size: 36, color: Color(0xFF6750A4)),
                                      onPressed: () {
                                        double current = double.tryParse(_currentAmount) ?? 0;
                                        setState(() {
                                          _currentAmount = (current + 1000).toString();
                                        });
                                      },
                                    ),
                                    // Teks Nominal
                                    Text(
                                      'Rp ${NumberFormat('#,##0', 'id_ID').format(double.tryParse(_currentAmount) ?? 0)}',
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            color: const Color(0xFF6750A4),
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    // Tombol Turunkan Nominal (sesuai desain)
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_down, size: 36, color: Color(0xFF6750A4)),
                                      onPressed: () {
                                        double current = double.tryParse(_currentAmount) ?? 0;
                                        if (current >= 1000) {
                                          setState(() {
                                            _currentAmount = (current - 1000).toString();
                                          });
                                        } else {
                                          setState(() { _currentAmount = '0'; });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      //     ],
                      //   ),
                      // // ),
                      const SizedBox(height: 16),

                      // 3. Keypad Numerik
                      // GlassCard(
                  
                        // borderRadius: 20,
                        // padding: const EdgeInsets.all(10), // Padding lebih kecil
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.8, // Lebar relatif terhadap tinggi
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            final List<String> keys = [
                              '1', '2', '3',
                              '4', '5', '6',
                              '7', '8', '9',
                              '000', '0', 'clear',
                            ];
                            final String key = keys[index];
                            return _KeypadButton(
                              label: key == 'clear' ? null : key,
                              icon: key == 'clear' ? Icons.backspace_outlined : null,
                              onTap: () => _updateAmount(key),
                            );
                          },
                        ),
                      // ),
                      const SizedBox(height: 16),

                      // 4. Pilihan Kategori Horizontal
                      SizedBox(
                        height: 90, // Tinggi tetap untuk scroll horizontal
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayedCategories.length,
                          itemBuilder: (context, index) {
                            final category = displayedCategories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _SmallCategoryButton(
                                category: category,
                                isSelected: _selectedCategory?.id == category.id,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Catatan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Note (Details, Date, etc)',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                            border: InputBorder.none, // Hapus border TextField
                            prefixIcon: const Icon(Icons.edit_note, color: AppColors.textSecondary),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 6. Tombol Simpan (di bawah, tidak ikut scroll)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    foregroundColor: const Color(0xFF6750A4),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget untuk tombol tipe transaksi (Income/Expense)
class _TransactionTypeButton extends StatelessWidget {
  final String label;
  final TransactionType type;
  final bool isSelected;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _TransactionTypeButton({
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == TransactionType.income ? Icons.arrow_upward : Icons.arrow_downward,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk tombol keypad numerik
class _KeypadButton extends StatefulWidget { // <-- 1. Ubah ke StatefulWidget
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({
    super.key, // Tambahkan Key
    this.label, 
    this.icon, 
    required this.onTap
  }); // Tambahkan super(key: key)

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  // 2. Tambahkan state untuk melacak "ditekan"
  bool _isPressed = false; 

  @override
  Widget build(BuildContext context) {
    // 3. Tentukan warna berdasarkan state
    // Saat ditekan (true), warna jadi putih (AppColors.glass)
    // Saat dilepas (false), warna jadi hitam (default)
    final Color glassColor = _isPressed ? Colors.black  : AppColors.glass;

    return GestureDetector(
      onTap: widget.onTap, // Tetap jalankan fungsi utama

      // 4. Tambahkan event listener untuk men-set state
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
      behavior: HitTestBehavior.translucent, // Agar area transparan terdeteksi

      child: GlassCard(
        color: glassColor, // 5. Gunakan warna dinamis
        borderRadius: 20, 
        padding: const EdgeInsets.all(4), 
        child: Center(
          child: widget.label != null // Gunakan widget.label
              ? Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith( 
                        color: const Color(0xFF6750A4), 
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Icon(
                  widget.icon, // Gunakan widget.icon
                  color: const Color(0xFF6750A4), 
                  size: 24 
                ),
        ),
      ),
    );
  }
}