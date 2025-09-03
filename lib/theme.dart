import 'package:flutter/material.dart';

ThemeData lightMode=ThemeData(
  colorScheme: ColorScheme.light(
      surface: Colors.white,
      primary: Colors.white,
      secondary: Colors.black,
      tertiary: Colors.black54,
      inversePrimary: Colors.black38
  ),
  appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0.5,
      color: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      iconTheme: IconThemeData(
          color: Colors.black
      ),
      titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20
      )
  ),
  textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.purple.shade50,
      selectionHandleColor: Colors.purple.shade50
  ),
  brightness: Brightness.light,
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212),
    primary: Color(0xFF1E1E1E),
    secondary: Colors.white,
    tertiary: Colors.white54,
    inversePrimary: Colors.white70,
  ),
  appBarTheme: AppBarTheme(
    scrolledUnderElevation: 0.5,
    color: Color(0xFF1E1E1E),
    elevation: 0.5,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Colors.purple.shade700.withOpacity(0.4),
    selectionHandleColor: Colors.purple.shade200,
  ),
  brightness: Brightness.dark,
);