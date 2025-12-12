import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk BackdropFilter

// Import relatif
import 'add_category_screen.dart'; 
import 'dashboard_screen.dart'; 

import 'profile_screen.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'statistic_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const StatisticScreen(), // Halaman Statistik
    const AddCategoryScreen(), // Halaman Kategori
    const ProfileScreen(), // Halaman Profil
  ];

  static const List<String> _widgetTitles = <String>[
    'Hello!',
    'Statistic',
    'Category',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    // 1. Bungkus semuanya dengan Stack
    return Stack(
      children: [
        // 2. Taruh background.png di lapisan paling bawah
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 3. Taruh Scaffold di atas background
        Scaffold(
          backgroundColor: Colors.transparent, // <-- PENTING: Buat Scaffold transparan
          appBar: AppBar(
            // 2. LOGIKA JUDUL DINAMIS
            // Jika index 0 (Homepage), tampilkan dari UserProvider
            // Jika bukan, ambil dari _widgetTitles seperti biasa
            title: _selectedIndex == 0
                ? Text('Halo ${userProvider.nickname}!') 
                : Text(_widgetTitles.elementAt(_selectedIndex)),
          ),
          
          body: _widgetOptions.elementAt(_selectedIndex),

          bottomNavigationBar: Container(
            // Trik untuk membuat BNB tembus pandang
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ClipRRect(
              // Ini yang memberi efek blur (Glassmorphism)
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
                  // Tema (warna, dll) sudah diatur di theme.dart
                  // Pastikan backgroundColor di theme diatur ke transparent
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}