import 'package:flutter/material.dart';
import 'add_category_screen.dart'; // Ganti 'project_name'
import 'dashboard_screen.dart'; // Ganti 'project_name'
import 'add_transaction_screen.dart';
import '../utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    // Placeholder untuk halaman Kategori jika Anda mau memisahkannya
    const AddCategoryScreen(), // Saya gunakan ini sebagai halaman ke-2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.card,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Sisi Kiri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_filled,
                          color: _selectedIndex == 0 ? AppColors.primary : AppColors.textSecondary,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: _selectedIndex == 0 ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sisi Kanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          color: _selectedIndex == 1 ? AppColors.primary : AppColors.textSecondary,
                        ),
                        Text(
                          'Kategori',
                          style: TextStyle(
                            color: _selectedIndex == 1 ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}