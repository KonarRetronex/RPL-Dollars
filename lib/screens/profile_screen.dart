import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fungsi untuk memilih gambar
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Simpan path gambar ke provider
      Provider.of<UserProvider>(context, listen: false).updateImage(image.path);
    }
  }

  // Fungsi untuk menampilkan dialog edit text
  void _showEditDialog(BuildContext context, String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue == '-' ? '' : currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2146),
          title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Stack(
      children: [
        // 1. Background Image
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

        // 2. Content
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Header Title
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF6750A4), // Warna ungu gelap sesuai gambar
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Profile Picture
                  GestureDetector(
                    onTap: () => _pickImage(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2), // Border hitam tipis
                            color: Colors.grey[300],
                            image: userProvider.imagePath.isNotEmpty
                                ? DecorationImage(
                                    image: FileImage(File(userProvider.imagePath)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: userProvider.imagePath.isEmpty
                              ? const Icon(Icons.camera_alt_outlined, size: 50, color: Colors.black54)
                              : null,
                        ),
                        // Plus Icon
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black, // Warna lingkaran plus
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Edit Profile Button (Capsule)
                  GestureDetector(
                    onTap: () {
                      // NAVIGASI KE HALAMAN EDIT PROFILE
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6A4BD), 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Edit profile',
                        style: TextStyle(
                          color: Color(0xFF4A3780),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Profile Fields (HANYA MENAMPILKAN DATA, TIDAK BISA KLIK)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileDisplayField(label: 'Nickname', value: userProvider.nickname),
                        _ProfileDisplayField(label: 'Full Name', value: userProvider.name),
                        _ProfileDisplayField(label: 'Email', value: userProvider.email),
                        _ProfileDisplayField(label: 'Language', value: userProvider.language),
                        _ProfileDisplayField(label: 'Theme', value: userProvider.theme),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Log Out Button
                  GestureDetector(
                    onTap: () {
                       // Tampilkan konfirmasi logout
                       showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text('Are you sure you want to clear your data?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  userProvider.logOut();
                                  Navigator.pop(ctx);
                                }, 
                                child: const Text('Log Out', style: TextStyle(color: Colors.red))
                              ),
                            ],
                          ),
                       );
                    },
                    child: GlassCard(
                      borderRadius: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      color: Colors.white.withOpacity(0.2), // Sedikit lebih terang
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Agar tidak memenuhi lebar
                        children: [
                          const Icon(Icons.logout, color: Color(0xFF6750A4)), // Ikon panah/logout
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF6750A4),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 20), // Spacer agar agak panjang
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget Helper untuk Menampilkan Data (Statis/Tidak bisa diklik)
class _ProfileDisplayField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDisplayField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column( // Hapus InkWell/GestureDetector
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}