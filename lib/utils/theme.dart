import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background, // Latar belakang gelap
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.background,
      brightness: Brightness.dark, // PENTING: Atur ke dark mode
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    // AppBar transparan
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Transparan
      elevation: 0,
      centerTitle: false, // Sesuai gambar, judul di kiri
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 24, // Lebih besar
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    
    // Teks
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      labelMedium: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
    ),
    
    // Hapus cardTheme (kita akan pakai GlassCard)
    // Hapus floatingActionButtonTheme (kita tidak pakai FAB)
    
    // Tema Bottom Navigasi
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.glass.withOpacity(0.1), // Efek kaca
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}