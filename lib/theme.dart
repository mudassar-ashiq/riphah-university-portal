import 'package:flutter/material.dart';

/// App theme in the official Riphah International University —
/// Sahiwal Campus colours, sampled from riphahsahiwal.edu.pk:
/// deep navy and gold on a warm cream background, white cards.
ThemeData buildRiphahTheme() {
  const navy = Color(0xFF003366);
  const navyDark = Color(0xFF001E35);
  const gold = Color(0xFFFFCC22);
  const cream = Color(0xFFF7F5EA);
  const heading = Color(0xFF2F3648);
  const body = Color(0xFF5A6474);
  const meta = Color(0xFF8A8F98);
  const danger = Color(0xFFDC2626);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: cream,
    colorScheme: const ColorScheme.light(
      primary: navy,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: navyDark,
      surface: Colors.white,
      onSurface: heading,
      error: danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navyDark,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: heading, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: heading, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: heading, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: body),
      bodyMedium: TextStyle(color: body),
      bodySmall: TextStyle(color: meta),
    ),
    // Primary actions are gold pills with dark-navy text, like the
    // buttons on the university website.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: navyDark,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: navyDark,
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: navy,
        side: const BorderSide(color: navy),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: navy),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: navy),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: navyDark,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
  );
}
