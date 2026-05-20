import 'package:flutter/material.dart';

/// Tunable constants for the animated splash screen.
///
/// All durations + curves live in one place so the splash can be re-tuned
/// without touching the animation widget.
class SplashConstants {
  SplashConstants._();

  // ── Phase durations ────────────────────────────────────────────────────────

  /// Phase 1: logo scale + fade-in, glow halo appears.
  static const Duration logoEntry = Duration(milliseconds: 600);

  /// Phase 2: wordmark slide-up + fade (overlaps Phase 1's tail).
  static const Duration wordmarkEntry = Duration(milliseconds: 500);

  /// Wordmark begins this far into Phase 1 (creates the overlap).
  static const Duration wordmarkDelay = Duration(milliseconds: 400);

  /// Phase 3: subtle infinite breathing pulse on the logo.
  static const Duration breathPeriod = Duration(milliseconds: 2400);

  /// Phase 4: fade-out duration when bootstrap completes.
  static const Duration fadeOut = Duration(milliseconds: 280);

  // ── Hold timing ────────────────────────────────────────────────────────────

  /// Minimum total time the splash is visible before it can fade out, even if
  /// async bootstrap finishes faster. Keeps the experience consistent.
  /// Increased to 2500ms to ensure splash is visible on subsequent app launches
  /// when providers load from cached SharedPreferences.
  static const Duration minHold = Duration(milliseconds: 2500);

  /// Hard cap. If bootstrap exceeds this, we fade out anyway and let the app
  /// surface its own loading/error state. Prevents an indefinite splash.
  static const Duration maxHold = Duration(seconds: 8);

  // ── Reduce-motion overrides ────────────────────────────────────────────────

  /// When the OS requests reduced motion, collapse Phase 1 + 2 to this single
  /// shorter duration and skip Phase 3 entirely.
  static const Duration reducedEntry = Duration(milliseconds: 200);

  // ── Visual ─────────────────────────────────────────────────────────────────

  /// Brand background. Must match values-v31/styles.xml's
  /// android:windowSplashScreenBackground and values/colors.xml's
  /// splash_background to make the native -> Flutter handoff seamless.
  static const Color background = Color(0xFF060D21);

  /// Path to the icon asset declared in pubspec.yaml.
  static const String iconAsset = 'assets/icons/custom/smritive-icon.png';

  /// Wordmark text. Rendered with GoogleFonts.nunito to match AppTheme.
  static const String wordmark = 'Smritive';
}
