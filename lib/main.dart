import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
//import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:roka_ai/providers/chat_provider.dart';

import 'package:roka_ai/databases/ai_model_db.dart';
import 'package:roka_ai/providers/user_preferences_provider.dart';
import 'package:roka_ai/schemas/chat_session_model.dart';
import 'package:roka_ai/schemas/user_preferences.dart';
import 'package:roka_ai/services/llama_manager.dart';
import 'package:roka_ai/themes/app_themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:roka_ai/databases/chat_message_db.dart';
import 'package:roka_ai/databases/chat_session_db.dart';
import 'package:roka_ai/schemas/ai_model_model.dart';
import 'package:roka_ai/screens/model_manager_screen.dart';
import 'package:roka_ai/screens/chat_screen.dart';
import 'package:roka_ai/screens/settings_screen.dart';

late Isar isar; // creating Isar variable named isar
bool isDarkMode = true;
// String serverAddress = "http://127.0.0.1:8000";

final llamaManager = LlamaManager();

// it the main function that runs / starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensuring that widgets are initialized

  final dir =
      await getApplicationSupportDirectory(); // getiing the directory in which Isar data will be stored
  // initializing Isar with schemas and storage path
  isar = await Isar.open([
    AiModelSchema,
    ChatSessionSchema,
    ChatMessageSchema,
    UserPreferencesSchema,
  ], directory: dir.path);

  final prefs = await isar.userPreferences.get(0);
  isDarkMode = prefs?.isDarkMode ?? true;

  // serverAddress = prefs?.serverAddress ?? "http://127.0.0.1:8000";

  // this func is from material.dart which runs the app
  runApp(
    // defining MultiProvider that allows to use multiple provider in app
    MultiProvider(
      // list of providers
      providers: [
        // this type of provider helps to re-build/refresh widgets/UI when value in it changes
        ChangeNotifierProvider(
          create: (_) =>
              ChatProvider(
                  ChatSessionDb(isar),
                  ChatMessageDb(isar),
                ) // creating ChatSessionDb and ChatMessageDb which will have session and message infos
                ..loadSessions(), // calling loadSession function when creating ChatSessionDb so UI can Have previous session info
        ),
        ChangeNotifierProvider(
          // creating AiModelDb as well to handle model's list and other related
          create: (_) => AiModelDb(isar),
        ),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider(isar)),
      ],
      child: App(isDarkMode: isDarkMode),
    ),
  );
}

class App extends StatelessWidget {
  bool isDarkMode;
  App({required this.isDarkMode, super.key});

  @override
  Widget build(BuildContext context) {
    llamaManager.setLibraryPath();
    isDarkMode = Provider.of<UserPreferencesProvider>(context).isDark;
    return Consumer<UserPreferencesProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => ChatScreen(),
            '/settings': (context) => SettingsScreen(),
            '/model_manager': (context) => ModelManagerScreen(),
          },
        );
      },
    );
  }
}
