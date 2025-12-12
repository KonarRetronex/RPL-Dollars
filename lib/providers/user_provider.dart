import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class UserProvider with ChangeNotifier {
  final Box _userBox = Hive.box('user_prefs'); // Pastikan box ini dibuka di main.dart nanti

  String _nickname = '';
  String _name = '';
  String _email = '';
  String _imagePath = '';
  String _language = 'English';
  String _theme = 'Dark Mode';

  String get nickname => _nickname;
  String get name => _name;
  String get email => _email;
  String get imagePath => _imagePath;
  String get language => _language;
  String get theme => _theme;

  UserProvider() {
    _loadUserData();
  }

  void _loadUserData() {
    _name = _userBox.get('name', defaultValue: '-');
    _email = _userBox.get('email', defaultValue: '-');
    _imagePath = _userBox.get('imagePath', defaultValue: '');
    _language = _userBox.get('language', defaultValue: 'English');
    _theme = _userBox.get('theme', defaultValue: 'Dark Mode');
    notifyListeners();
  }

  Future<void> updateProfile({String? nickname, String? name, String? email, String? language, String? theme}) async {
    if (nickname != null) {
      _nickname = nickname;
      await _userBox.put('nickname', nickname);
    }
    
    if (name != null) {
      _name = name;
      await _userBox.put('name', name);
    }
    if (email != null) {
      _email = email;
      await _userBox.put('email', email);
    }
    if (language != null) {
      _language = language;
      await _userBox.put('language', language);
    }
    if (theme != null) {
      _theme = theme;
      await _userBox.put('theme', theme);
    }
    notifyListeners();
  }

  Future<void> updateImage(String path) async {
    _imagePath = path;
    await _userBox.put('imagePath', path);
    notifyListeners();
  }
  
  Future<void> logOut() async {
      // Logika logout (misal clear data atau navigasi ke login)
      // Disini kita reset saja sebagai contoh
      await _userBox.clear();
      _loadUserData();
  }
}