import 'package:flutter/material.dart';

/// צבעים ועיצוב מרכזיים - פלטה רומנטית, אלגנטית ומודרנית.
class AppPalette {
  static const Color rose = Color(0xFFD98AA0);
  static const Color deepRose = Color(0xFF9C4A63);
  static const Color blush = Color(0xFFF6E7EC);
  static const Color gold = Color(0xFFC9A86A);
  static const Color charcoal = Color(0xFF2B2330);
  static const Color cream = Color(0xFFFDF8F5);

  /// גרדיאנט ברירת מחדל למסך כשאין תמונת רקע מותאמת.
  static const LinearGradient romanticGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3B2233),
      Color(0xFF6E3A52),
      Color(0xFFB76E84),
    ],
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.deepRose,
        primary: AppPalette.deepRose,
        secondary: AppPalette.gold,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppPalette.cream,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
