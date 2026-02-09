import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF3A4A7D); // Professional Royal Blue
const Color kExamplesTeal = Color(0xFF3A4A7D);

ThemeData theme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Muli',
    scaffoldBackgroundColor:
        const Color(0xFFF8F9FD), // Slightly off-white for premium feel
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryBlue,
      primary: kPrimaryBlue,
      secondary: const Color(0xFFFF4081),
      surface: Colors.white,
      onSurface: const Color(0xFF1A1A1A),
      background: const Color(0xFFF8F9FD),
      error: Colors.redAccent,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FD),
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Muli',
      ),
    ),
    textTheme: textTheme(isDark: false),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Muli',
    ),
  );
}

TextTheme textTheme({required bool isDark}) {
  final color = isDark ? Colors.white : Colors.black;
  final body1Color = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A1A);
  final body2Color = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF4A4A4A);

  return TextTheme(
    displayLarge:
        TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
    titleLarge:
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    bodyLarge: TextStyle(fontSize: 16, color: body1Color),
    bodyMedium: TextStyle(fontSize: 14, color: body2Color),
    labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.black : Colors.white),
  );
}

// Dark Theme for "Premium/Cyber" look
ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Muli',
    scaffoldBackgroundColor: const Color(0xFF121212), // Standard Dark
    cardColor: const Color(0xFF1E1E1E), // Explicit card color
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryBlue,
      primary: kPrimaryBlue,
      secondary: kExamplesTeal,
      surface: const Color(0xFF1E1E1E), // Card background
      onSurface: Colors.white,
      background: const Color(0xFF121212),
      error: const Color(0xFFCF6679),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF121212),
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Muli',
      ),
    ),
    textTheme: textTheme(isDark: true),
  );
}
