import 'package:flutter/material.dart';

class AppThemes {
  static Color accentDark = Color(0xFF07B0FF);
  static Color accentBgDark = Color(0xFF004B6E);
  static Color accentLight = Color(0xFF07B0FF);
  static Color accentBgLight = Color(0xFF3BC1FF);

  static Color bgDark = Color(0xFF000000);
  static Color bgLight = Color(0xFFEDEDED);

  static Color primaryDark = Color(0xFF131313);
  static Color primarylight = Color(0xFFF1F1F1);

  static Color secondaryDark = Color(0xFF1A1A1A);
  static Color secondaryLight = Color(0xFFE1E1E1);

  static Color tertieryDark = Color.fromARGB(255, 46, 46, 46);
  static Color tertieryLight = Color(0xFF585858);

  static Color primaryTextDark = Color(0xFFEFEFEF);
  static Color primaryTextLight = Color(0xFF000000);

  static Color secondaryTextDark = Color(0xFFD5D5D5);
  static Color secondaryTextLight = Color(0xFF353535);

  static Color tertiaryTextDark = Color(0xFF5E5E5E);
  static Color tertiaryTextLight = Color(0xFF7F7F7F);

  static Color textFieldBgDark = Colors.black;
  static Color textFieldBgLight = Colors.white;

  static Color noColor = const Color.fromARGB(0, 255, 255, 255);

  // ---------------Dark Theme -----------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: bgDark,
    appBarTheme: AppBarTheme(
      backgroundColor: noColor,
      foregroundColor: bgLight,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: primaryDark),
  );

  // -----------------light Theme -------------------
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: bgLight,
    scaffoldBackgroundColor: primarylight,
    appBarTheme: AppBarTheme(
      backgroundColor: noColor,
      foregroundColor: primaryDark,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: primarylight),
  );
}
