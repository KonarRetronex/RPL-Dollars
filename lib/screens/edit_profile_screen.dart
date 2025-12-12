import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../widgets/glass_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller untuk input text
  late TextEditingController _nicknameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Variabel untuk Dropdown
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Purple';

  @override
  void initState() {
    super.initState();
    // Ambil data user saat ini untuk mengisi form otomatis
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nicknameController = TextEditingController(text: userProvider.nickname);
    _nameController = TextEditingController(text: userProvider.name);
    _emailController = TextEditingController(text: userProvider.email);
    
    // Set dropdown value (jika ada logic lain nanti, sekarang default English/Purple)
    // _selectedLanguage = userProvider.language; 
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // Simpan ke Provider (Hive)
    Provider.of<UserProvider>(context, listen: false).updateProfile(
      nickname: _nicknameController.text,
      name: _nameController.text,
      email: _emailController.text,
      language: _selectedLanguage,
      theme: _selectedTheme,
    );

    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        // 2. Form Content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input: Nickname
                _buildLabel('Nickname'),
                _buildTextInput(_nicknameController),
                const SizedBox(height: 16),

                // Input: Full Name
                _buildLabel('Full Name'),
                _buildTextInput(_nameController),
                const SizedBox(height: 16),

                // Input: Email
                _buildLabel('Email'),
                _buildTextInput(_emailController),
                const SizedBox(height: 16),

                // Dropdown: Language
                _buildLabel('Language'),
                _buildDropdown(
                  value: _selectedLanguage,
                  items: ['English'], // Hanya satu opsi
                  onChanged: (val) {
                    setState(() => _selectedLanguage = val!);
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown: Theme
                _buildLabel('Theme'),
                _buildDropdown(
                  value: _selectedTheme,
                  items: ['Purple'], // Hanya satu opsi
                  onChanged: (val) {
                    setState(() => _selectedTheme = val!);
                  },
                ),
                const SizedBox(height: 40),

                // Tombol Save
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFE8C4), // Warna kuning gading seperti di gambar
                      foregroundColor: const Color(0xFF4A3780), // Teks ungu
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(150, 50),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Widget Helper untuk Input Text (Glass Style)
  Widget _buildTextInput(TextEditingController controller) {
    return GlassCard(
      borderRadius: 15,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.white.withOpacity(0.2), // Latar transparan kebiruan
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // Widget Helper untuk Dropdown (Glass Style)
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return GlassCard(
      borderRadius: 15,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.white.withOpacity(0.2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF4e348b), // Warna background menu dropdown
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          isExpanded: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}