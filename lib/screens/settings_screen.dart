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
      backgroundColor: isDarkMode ? AppThemes.bgDark : AppThemes.bgLight,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            color: isDarkMode
                ? AppThemes.primaryTextDark
                : AppThemes.primaryTextLight,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode
                ? AppThemes.primaryTextDark
                : AppThemes.primaryTextLight,
          ),
        ),
      ),
      body: Column(
        children: [
          SettingOptionTile(
            title: Text(
              "Dark Theme",
              style: TextStyle(
                fontSize: titleSize,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
            ),
            leading: Icon(
              Icons.dark_mode_outlined,
              size: iconSize,
              color: isDarkMode
                  ? AppThemes.primaryTextDark
                  : AppThemes.primaryTextLight,
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) async {
                await Provider.of<UserPreferencesProvider>(
                  context,
                  listen: false,
                ).toggleTheme(value);
                setState(() {});
              },
            ),
          ),
          SettingOptionTile(
            title: Text(
              "Language",
              style: TextStyle(
                fontSize: titleSize,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
            ),
            leading: Icon(
              Icons.language,
              size: iconSize,
              color: isDarkMode
                  ? AppThemes.primaryTextDark
                  : AppThemes.primaryTextLight,
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down_circle_outlined,
                size: iconSize,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
              initialValue: currenetLanguage,
              onSelected: (value) => (),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "English",
                  child: Text(
                    "English",
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.primaryTextDark
                          : AppThemes.primaryTextLight,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: "Italian",
                  child: Text(
                    "Italian",
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.primaryTextDark
                          : AppThemes.primaryTextLight,
                    ),
                  ),
                ),
                PopupMenuItem(value: "Hindi", child: Text("Hindi")),
                PopupMenuItem(
                  value: "Gujarati",
                  child: Text(
                    "Gujarati",
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.primaryTextDark
                          : AppThemes.primaryTextLight,
                    ),
                  ),
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemes.secondaryDark
                  : AppThemes.secondaryLight,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_cloudy_outlined, size: iconSize),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Server Address",
                          style: TextStyle(fontSize: titleSize),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 200,
                        child: TextField(
                          controller: _serverTextFieldController,
                          decoration: InputDecoration(
                            hintText: ApiService.server,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (value) => ApiService.server = value,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SettingOptionTile(
            title: Text(
              "About",
              style: TextStyle(
                fontSize: titleSize,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
            ),
            subTitle: Row(
              spacing: 8,
              children: [
                Text(
                  "Local GPT",
                  style: TextStyle(
                    fontSize: subTitleSize,
                    color: isDarkMode
                        ? AppThemes.primaryTextDark
                        : AppThemes.primaryTextLight,
                  ),
                ),
                Icon(Icons.circle, size: 5),
                Text(
                  "Version 1.0",
                  style: TextStyle(
                    fontSize: subTitleSize,
                    color: isDarkMode
                        ? AppThemes.primaryTextDark
                        : AppThemes.primaryTextLight,
                  ),
                ),
              ],
            ),
            leading: Icon(
              Icons.info_outline,
              size: iconSize,
              color: isDarkMode
                  ? AppThemes.primaryTextDark
                  : AppThemes.primaryTextLight,
            ),
            overridePaddingV: 2,
          ),
        ],
      ),
    );
  }
}
