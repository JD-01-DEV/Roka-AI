import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:localgpt/schemas/user_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final Isar _isar;
  UserPreferencesProvider(this._isar);

  bool _isDark = true;
  bool get isDark => _isDark;

  String _serverAddress = "http://127.0.0.1:8000";
  String get serverAddreess => _serverAddress;

  Future<bool> getIsDarkMode() async {
    final prefs = await _isar.userPreferences.get(1);
    if (prefs == null) {
      // Optionally, create a new UserPreferences object here if needed.
      return true;
    }
    _isDark = prefs.isDarkMode; // Update local state
    return _isDark;
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    final prefs = await _isar.userPreferences.get(1);
    if (prefs == null) {
      // Create a new UserPreferences object if it doesn't exist
      final newPrefs = UserPreferences()
        ..id = 1
        ..isDarkMode = isDarkMode;
      await _isar.writeTxn(() => _isar.userPreferences.put(newPrefs));
    } else {
      final pref = prefs..isDarkMode = isDarkMode;
      await _isar.writeTxn(() => _isar.userPreferences.put(pref));
    }
    _isDark = isDarkMode;
    notifyListeners();
  }

  Future<void> updateServerAddress(String serverAddreess) async {
    final prefs = await _isar.userPreferences.get(1);
    if (prefs == null) {
      // Create a new UserPreferences object if it doesn't exist
      final newPrefs = UserPreferences()
        ..id = 1
        ..serverAddress = serverAddreess;
      await _isar.writeTxn(() => _isar.userPreferences.put(newPrefs));
    } else {
      final pref = prefs..serverAddress = serverAddreess;
      await _isar.writeTxn(() => _isar.userPreferences.put(pref));
    }
    _serverAddress = serverAddreess;
    notifyListeners();
  }
}
