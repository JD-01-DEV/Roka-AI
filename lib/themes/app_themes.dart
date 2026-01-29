import 'package:flutter/material.dart';

class AppThemes {
  static Color accentDark = Color(0xFF17B6FF);
  static Color accentBgDark = Color(0xFF004B6E);
  static Color accentLight = Color(0xFF17B6FF);
  static Color accentBgLight = Color(0xFF3BC1FF);

  static Color bgDark = Color(0xFF000000);
  static Color bgLight = Color(0xFFEDEDED);

  static Color primaryDark = Color(0xFF131313);
  static Color primarylight = Color(0xFFF1F1F1);

  static Color secondaryDark = Color(0xFF1A1A1A);
  static Color secondaryLight = Color(0xFFE1E1E1);

  static Color tertieryDark = Color(0xFF2E2E2E);
  static Color tertieryLight = Color(0xFF585858);

  static Color primaryTextDark = Color(0xFFEFEFEF);
  static Color primaryTextLight = Color(0xFF000000);

  static Color secondaryTextDark = Color(0xFFD5D5D5);
  static Color secondaryTextLight = Color(0xFF353535);

  static Color tertiaryTextDark = Color.fromARGB(255, 71, 71, 71);
  static Color tertiaryTextLight = Color(0xFFD8D8D8);

  static Color textFieldBgDark = Colors.black;
  static Color textFieldBgLight = Colors.white;

  static Color noColor = const Color.fromARGB(0, 255, 255, 255);

  // Helper method for BoxDecoration
  static BoxDecoration boxDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? secondaryDark : secondaryLight,
      borderRadius: BorderRadius.circular(8),
    );
  }

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

    textTheme: TextTheme(
      bodyLarge: TextStyle(color: primaryTextDark),
      bodyMedium: TextStyle(color: primaryTextDark),
      bodySmall: TextStyle(color: secondaryTextDark),
      titleLarge: TextStyle(color: primaryTextDark),
      titleMedium: TextStyle(color: primaryTextDark),
      titleSmall: TextStyle(color: secondaryTextDark),
      labelLarge: TextStyle(color: primaryTextDark),
      labelMedium: TextStyle(color: secondaryTextDark),
      labelSmall: TextStyle(color: tertiaryTextDark),
    ),
    iconTheme: IconThemeData(color: primaryTextDark),

    cardTheme: CardThemeData(
      color: secondaryDark,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
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
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: primaryTextLight),
      bodyMedium: TextStyle(color: primaryTextLight),
      bodySmall: TextStyle(color: secondaryTextLight),
      titleLarge: TextStyle(color: primaryTextLight),
      titleMedium: TextStyle(color: primaryTextLight),
      titleSmall: TextStyle(color: secondaryTextLight),
      labelLarge: TextStyle(color: primaryTextLight),
      labelMedium: TextStyle(color: secondaryTextLight),
      labelSmall: TextStyle(color: tertiaryTextLight),
    ),
    iconTheme: IconThemeData(color: primaryTextLight),

    cardTheme: CardThemeData(
      color: secondaryLight,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
