import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:roka_ai/providers/chat_provider.dart';

import 'package:roka_ai/databases/ai_model_db.dart';
import 'package:roka_ai/providers/user_preferences_provider.dart';
import 'package:roka_ai/schemas/chat_session_model.dart';
import 'package:roka_ai/schemas/user_preferences.dart';
import 'package:roka_ai/screens/live_mode_screen.dart';
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

late Isar isar;
bool isDarkMode = true;
final llamaManager = LlamaManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensuring that widgets are initialized

  final dir = await getApplicationSupportDirectory();
  isar = await Isar.open([
    AiModelSchema,
    ChatSessionSchema,
    ChatMessageSchema,
    UserPreferencesSchema,
  ], directory: dir.path);

  final prefs = await isar.userPreferences.get(0);
  isDarkMode = prefs?.isDarkMode ?? true;

  runApp(
    // Allow to use multiple provider in app
    MultiProvider(
      // list of providers
      providers: [
        // [ChangeNotifierProvider] refreshes UI when value changes
        ChangeNotifierProvider(
          create: (_) =>
              ChatProvider(ChatSessionDb(isar), ChatMessageDb(isar))
                ..loadSessions(), // loads session initialy
        ),
        ChangeNotifierProvider(create: (_) => AiModelDb(isar)),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider(isar)),
      ],
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    llamaManager.setLibraryPath();
    final provider = Provider.of<UserPreferencesProvider>(context);
    provider.getIsDarkMode();

    setState(() {
      isDarkMode = provider.isDark;
    });

    debugPrint("main: $isDarkMode");
    return Consumer<UserPreferencesProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          theme: isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => ChatScreen(),
            '/settings': (context) => SettingsScreen(),
            '/model_manager': (context) => ModelManagerScreen(),
            '/live_mode': (context) => LiveModeScreen(),
          },
        );
      },
    );
  }
}
