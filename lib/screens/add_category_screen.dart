import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../utils/colors.dart';
import '../widgets/icon_picker.dart';
import '../widgets/glass_card.dart'; // <-- 1. IMPORT WIDGET GLASS_CARD
import 'category_detail_screen.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  IconData? _selectedIcon;

  void _submitCategory() {
    if (_formKey.currentState!.validate() && _selectedIcon != null) {
      Provider.of<CategoryProvider>(context, listen: false).addCategory(
        _nameController.text,
        _selectedType,
        _selectedIcon!.codePoint,
      );
      
      _nameController.clear();
      setState(() {
        _selectedIcon = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Category Added!')),
      );
    } else if (_selectedIcon == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an icon for the category.')),
      );
    }
  }

  void _pickIcon() async {
    final IconData? icon = await showDialog<IconData>(
      context: context,
      builder: (context) => const IconPicker(),
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gambar Latar Belakang
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
          // appBar: AppBar(
          //   title: const Text('Manajemen Kategori'),
          // ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Form Tambah Kategori
                Form(
                  key: _formKey,
                  // 2. GANTI CARD DENGAN GLASSCARD
                  child: GlassCard(
                    padding: const EdgeInsets.all(16.0), // Padding diatur oleh GlassCard
                    borderRadius: 20, // Radius standar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Category',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Category Name'),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Category Name cannot be empty' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<TransactionType>(
                                initialValue: _selectedType,
                                decoration: const InputDecoration(labelText: 'Income/Expense'),
                                items: const [
                                  DropdownMenuItem(
                                    value: TransactionType.expense,
                                    child: Text('Expense'),
                                  ),
                                  DropdownMenuItem(
                                    value: TransactionType.income,
                                    child: Text('Income'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() { _selectedType = value; });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                
                                const Text("Icon", style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: const Color(0xFF6750A4), // <-- 1. Tambah warna background (ungu tua)
                                    foregroundColor: Colors.white,           // <-- 2. Tambah warna ikon (putih)
                                    child: Icon(_selectedIcon ?? Icons.add, size: 24),
                                  ),
                                  onPressed: _pickIcon,
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitCategory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50)
                          ),
                          child: const Text('Save Category'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Daftar Kategori
                Expanded(
                  child: Consumer<CategoryProvider>(
                    builder: (context, catProvider, child) {
                      return ListView.builder(
                        itemCount: catProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = catProvider.categories[index];
                          // 3. GANTI CARD DENGAN GLASSCARD
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0), // Ini jadi 'margin'
                            child: GlassCard(
                              borderRadius: 15,
                              padding: EdgeInsets.zero, // Biarkan ListTile yg atur padding
                              child: ListTile(
                                onTap: () { // <-- TAMBAHKAN BLOK INI
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // Arahkan ke screen baru dan kirim data kategori
                                      builder: (context) => CategoryDetailScreen(category: category),
                                    ),
                                  );
                                },
                                leading: Icon(
                                  IconData(category.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
                                  color: AppColors.textPrimary,
                                ),
                                title: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category.type == TransactionType.income ? 'Income' : 'Expense',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: category.type == TransactionType.income
                                            ? AppColors.income
                                            : AppColors.expense,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Category'),
                                            content: Text('Are you sure want to delete this category "${category.name}"?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () => Navigator.of(ctx).pop(),
                                              ),
                                              TextButton(
                                                child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
                                                onPressed: () {
                                                  catProvider.deleteCategory(category.id);
                                                  Navigator.of(ctx).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}