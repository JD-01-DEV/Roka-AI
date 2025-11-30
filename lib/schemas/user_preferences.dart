import 'package:isar/isar.dart';

part 'user_preferences.g.dart';

@collection
class UserPreferences {
  Id id = 1;

  @Index()
  bool isDarkMode = false;

  String languageCode = 'en'; // e.g. "en", "hi", "es"

  String serverAddress = "http://127.0.0.1:8000";
}
