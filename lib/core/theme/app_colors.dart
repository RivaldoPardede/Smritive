import 'package:flutter/material.dart';

/// All color tokens defined in ui.md.
/// Reference these constants everywhere — never hardcode colors inline.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF060D21); // Smritive Navy
  static const Color primaryLight = Color(0xFFE0E7FF); // Indigo Light
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimary = Color(0xFF060D21); // Navy text
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  static const Color divider = Color(0xFFE2E8F0); // Slate 200
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
