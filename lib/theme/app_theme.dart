import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2D4B3E);
  static const Color secondaryColor = Color(0xFF4A6B5D);
  static const Color backgroundColor = Color(0xFFE2F0D9);

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;

  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static BoxDecoration errorContainerDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(borderRadiusSm),
    );
  }

  static TextStyle errorTextStyle(ThemeData theme) {
    return TextStyle(
      color: theme.colorScheme.onErrorContainer,
      fontSize: 14,
    );
  }

  static BoxDecoration statusBadgeDecoration(Color statusColor) {
    return BoxDecoration(
      color: statusColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(borderRadiusMd),
      border: Border.all(color: statusColor),
    );
  }
}