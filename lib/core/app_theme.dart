import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const sage = Color(0xFF52796F);
  static const peach = Color(0xFFF2B5A7);
  static const cream = Color(0xFFFAF7F2);
  static const charcoal = Color(0xFF24332E);
  static const border = Color(0xFFE3E8E1);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'DM Sans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: sage,
        primary: sage,
        onPrimary: Colors.white,
        secondary: peach,
        onSecondary: charcoal,
        surface: cream,
        onSurface: charcoal,
      ),
    );
    TextStyle heading(TextStyle? style) =>
        (style ?? const TextStyle()).copyWith(
          fontFamily: 'Fraunces',
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: -.6,
          height: 1.16,
        );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: heading(base.textTheme.displaySmall),
        headlineLarge: heading(base.textTheme.headlineLarge),
        headlineMedium: heading(base.textTheme.headlineMedium),
        headlineSmall: heading(base.textTheme.headlineSmall),
        titleLarge: heading(base.textTheme.titleLarge),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: charcoal,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: sage.withValues(alpha: .08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          foregroundColor: sage,
          side: const BorderSide(color: sage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: sage, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: peach,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: charcoal,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: sage,
        linearTrackColor: Color(0xFFE4EDE6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
