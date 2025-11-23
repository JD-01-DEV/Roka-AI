import 'package:flutter/material.dart';
import 'package:localgpt/main.dart';
import 'package:localgpt/providers/user_preferences_provider.dart';
import 'package:localgpt/services/api_service.dart';
import 'package:localgpt/themes/app_themes.dart';
import 'package:localgpt/widgets/setting_option_tile.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currenetLanguage = "English";

  double iconSize = 30;
  double titleSize = 18;
  double subTitleSize = 12;

  final _serverTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    isDarkMode = context.read<UserPreferencesProvider>().isDark;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle()),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          SettingOptionTile(
            title: Text("Dark Theme", style: TextStyle(fontSize: titleSize)),
            leading: Icon(Icons.dark_mode_outlined, size: iconSize),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) async {
                await context.read<UserPreferencesProvider>().toggleTheme(
                  value,
                );
                setState(() {
                  isDarkMode = value;
                  debugPrint("$isDarkMode");
                });
              },
            ),
          ),
          SettingOptionTile(
            title: Text("Language", style: TextStyle(fontSize: titleSize)),
            leading: Icon(Icons.language, size: iconSize),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down_circle_outlined, size: iconSize),
              initialValue: currenetLanguage,
              onSelected: (value) => (),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "English",
                  child: Text("English", style: TextStyle()),
                ),
                PopupMenuItem(
                  value: "Italian",
                  child: Text("Italian", style: TextStyle()),
                ),
                PopupMenuItem(value: "Hindi", child: Text("Hindi")),
                PopupMenuItem(
                  value: "Gujarati",
                  child: Text("Gujarati", style: TextStyle()),
                ),
              ],
              menuPadding: EdgeInsets.all(10),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(50),
              //   bottomRight: Radius.circular(20),
              // ),
              splashRadius: 5,
            ),
          ),

          SettingOptionTile(
            title: Text(
              "Server Address",
              style: TextStyle(fontSize: titleSize),
            ),
            leading: Icon(Icons.cloud_outlined, size: iconSize),
            trailing: SizedBox(
              // Use SizedBox or ConstrainedBox to control the width
              width: 150, // Set a reasonable width
              child: TextField(
                controller: _serverTextFieldController,
                decoration: InputDecoration(
                  hintText: ApiService.server,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onSubmitted: (value) => ApiService.server = value,
              ),
            ),
          ),
          SettingOptionTile(
            title: Text("About", style: TextStyle(fontSize: titleSize)),
            subTitle: Row(
              spacing: 8,
              children: [
                Text("Local GPT", style: TextStyle(fontSize: subTitleSize)),
                Icon(Icons.circle, size: 5),
                Text("Version 1.0", style: TextStyle(fontSize: subTitleSize)),
              ],
            ),
            leading: Icon(Icons.info_outline, size: iconSize),
            overridePaddingV: 2,
          ),
        ],
      ),
    );
  }
}
