import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF060D21);
  static const Color primaryLight = Color(0xFFE0E7FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF060D21);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFED4956);

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
