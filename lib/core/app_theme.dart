import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const sage = Color(0xFF52796F);
  static const peach = Color(0xFFF2B5A7);
  static const cream = Color(0xFFFAF7F2);
  static const charcoal = Color(0xFF24332E);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: sage,
      primary: sage,
      secondary: peach,
      surface: cream,
      onSurface: charcoal,
    ),
    scaffoldBackgroundColor: cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: charcoal,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: peach,
    ),
  );
}
