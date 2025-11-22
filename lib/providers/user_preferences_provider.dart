import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:localgpt/schemas/user_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final Isar _isar;
  UserPreferencesProvider(this._isar);

  bool _isDark = true;

  bool get isDark => _isDark;

  Future<bool> getIsDarkMode() async {
    final prefs = await _isar.userPreferences.get(1);

    if (prefs == null) return true;
    notifyListeners();
    return prefs.isDarkMode;
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    final prefs = await _isar.userPreferences.get(1);
    if (prefs == null) return;
    final pref = prefs..isDarkMode = isDarkMode;
    await _isar.userPreferences.put(pref);
    _isDark = isDarkMode;
    notifyListeners();
  }
}
