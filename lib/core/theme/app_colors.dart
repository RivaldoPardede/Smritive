import 'package:flutter/material.dart';

/// All color tokens defined in ui.md.
/// Reference these constants everywhere — never hardcode colors inline.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF060D21); // Smritive Navy
  static const Color primaryLight = Color(0xFFE5E5E5); // Light Gray
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF060D21); // Navy text
  static const Color textSecondary = Color(0xFF737373); // IG gray
  static const Color textHint = Color(0xFFBBBBBB);
  static const Color divider = Color(0xFFEFEFEF); // Subtle divider
  static const Color error = Color(0xFFED4956); // IG red/error

  // Gradient for the unread story rings
  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF060D21), // Smritive Deep Navy
      Color(0xFF1D4ED8), // Royal Blue
      Color(0xFF0EA5E9), // Cyan
    ],
  );
}
