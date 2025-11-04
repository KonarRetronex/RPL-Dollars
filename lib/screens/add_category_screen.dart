import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../utils/colors.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;

  void _submitCategory() {
    if (_formKey.currentState!.validate()) {
      Provider.of<CategoryProvider>(context, listen: false).addCategory(
        _nameController.text,
        _selectedType,
      );
      
      // Reset form
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori baru ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Tambah Kategori
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tambah Kategori Baru', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Kategori'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TransactionType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(labelText: 'Jenis'),
                        items: const [
                          DropdownMenuItem(
                            value: TransactionType.expense,
                            child: Text('Pengeluaran (Expense)'),
                          ),
                          DropdownMenuItem(
                            value: TransactionType.income,
                            child: Text('Pemasukan (Income)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50)
                        ),
                        child: const Text('Simpan Kategori'),
                      ),
                    ],
                  ),
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
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text(category.name),
                          trailing: Text(
                            category.type == TransactionType.income ? 'Income' : 'Expense',
                            style: TextStyle(
                              color: category.type == TransactionType.income
                                  ? AppColors.income
                                  : AppColors.expense,
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
    );
  }
}