import 'package:flutter/material.dart';
import 'add_category_screen.dart'; // Ganti 'project_name'
import 'dashboard_screen.dart'; // Ganti 'project_name'
import 'dart:ui'; // Untuk BackdropFilter
import '../utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman sesuai desain baru
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const Center(child: Text('Halaman Statistik')), // Placeholder
    const AddCategoryScreen(), // Halaman Kategori
    const Center(child: Text('Halaman Profil')), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Hapus FloatingActionButton
      
      // Gunakan BottomNavigationBar
      bottomNavigationBar: Container(
        // Ini trik untuk membuat BNB transparan
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Homepage',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Statistic',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              // Styling diambil dari theme.dart
            ),
          ),
        ),
      ),
    );
  }
}