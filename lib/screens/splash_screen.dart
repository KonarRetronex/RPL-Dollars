import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Pastikan import ini benar ke halaman utama Anda
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Tunggu 2 detik, lalu pindah ke DashboardScreen
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan gambar penuh memenuhi layar
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Pastikan path ini sesuai dengan lokasi gambar Anda
            image: AssetImage('assets/images/splash_background.png'),
            fit: BoxFit.cover, // Ini yang membuat gambar "melar" penuh
          ),
        ),
      ),
    );
  }
}