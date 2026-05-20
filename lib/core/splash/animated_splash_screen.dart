import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'splash_constants.dart';

/// Animated brand splash shown the moment Flutter takes over from the native
/// SplashScreen API. The transparent area / background colour matches the
/// native splash exactly so the seam is invisible.
///
/// Animation phases (configurable in [SplashConstants]):
///   1. Logo scales 0.85 -> 1.00 with fade-in + radial glow halo.
///   2. Wordmark slides up from +12 px and fades in (overlaps Phase 1's tail).
///   3. Subtle infinite breathing pulse on the logo (1.00 <-> 1.02).
///   4. Whole splash fades out when [readyToDismiss] is true.
///
/// When the OS reports [MediaQueryData.disableAnimations], Phase 3 is skipped
/// and Phases 1+2 collapse to a single short fade ([SplashConstants.reducedEntry]).
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({
    super.key,
    required this.readyToDismiss,
    required this.onDismissed,
  });

  /// When `true`, the splash starts its fade-out. Caller is responsible for
  /// flipping this flag once async bootstrap (auth, locale, min-hold) is done.
  final bool readyToDismiss;

  /// Called after the fade-out completes. Use it to swap the splash for the
  /// real app widget tree.
  final VoidCallback onDismissed;

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  // Phase 1+2: entry timeline (logo + wordmark).
  late final AnimationController _entry;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _wordmarkOffset;
  late final Animation<double> _wordmarkOpacity;

  // Phase 3: breathing pulse (infinite, slow).
  late final AnimationController _breath;

  // Phase 4: fade-out (driven on demand).
  late final AnimationController _fadeOut;

  bool? _reduceMotion;
  bool _dismissScheduled = false;

  @override
  void initState() {
    super.initState();

    // Lengths fixed up in didChangeDependencies once we can read MediaQuery.
    _entry = AnimationController(
      vsync: this,
      duration: SplashConstants.logoEntry,
    );
    _breath = AnimationController(
      vsync: this,
      duration: SplashConstants.breathPeriod,
    );
    _fadeOut =
        AnimationController(vsync: this, duration: SplashConstants.fadeOut)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onDismissed();
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Honour the platform reduce-motion setting.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _configureTimelines();
    }
  }

  void _configureTimelines() {
    if (_reduceMotion == true) {
      _entry.duration = SplashConstants.reducedEntry;
      // Single linear fade for both logo and wordmark; skip glow + breathing.
      _logoScale = AlwaysStoppedAnimation(1.0);
      _logoOpacity = CurvedAnimation(parent: _entry, curve: Curves.linear);
      _haloOpacity = AlwaysStoppedAnimation(0.0);
      _wordmarkOffset = AlwaysStoppedAnimation(0.0);
      _wordmarkOpacity = CurvedAnimation(parent: _entry, curve: Curves.linear);
    } else {
      _entry.duration = SplashConstants.logoEntry;

      // Phase 1 occupies 0.0 -> 1.0 of _entry.
      _logoScale = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
      _logoOpacity = CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      );
      _haloOpacity = CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      );

      // Phase 2 occupies the second half of _entry (delay then ease).
      const double wordmarkStart = 0.55;
      _wordmarkOffset = Tween<double>(begin: 12.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _entry,
          curve: const Interval(wordmarkStart, 1.0, curve: Curves.easeOutCubic),
        ),
      );
      _wordmarkOpacity = CurvedAnimation(
        parent: _entry,
        curve: const Interval(wordmarkStart, 1.0, curve: Curves.easeOut),
      );
    }

    // Restart entry whenever timelines change (covers reduce-motion mid-flight).
    _entry
      ..reset()
      ..forward();

    if (_reduceMotion != true) {
      _breath
        ..reset()
        ..repeat(reverse: true);
    } else {
      _breath.stop();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.readyToDismiss && !_dismissScheduled) {
      _dismissScheduled = true;
      _fadeOut.forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    _breath.dispose();
    _fadeOut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Logo size: 28% of the shorter side, clamped for tablets and tiny phones.
    final logoSize = (media.size.shortestSide * 0.28).clamp(96.0, 168.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _breath, _fadeOut]),
      builder: (context, _) {
        final breathScale = (_reduceMotion == true)
            ? 1.0
            : 1.0 + (_breath.value * 0.02); // 1.00 <-> 1.02
        final fade = 1.0 - _fadeOut.value;
        final entryComplete = _entry.status == AnimationStatus.completed;

        return Opacity(
          opacity: fade,
          child: ColoredBox(
            color: SplashConstants.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo + glow halo ────────────────────────────────────
                  SizedBox(
                    width: logoSize * 1.6,
                    height: logoSize * 1.6,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Halo: radial glow behind the logo.
                        Opacity(
                          opacity: _haloOpacity.value * 0.55,
                          child: Container(
                            width: logoSize * 1.6,
                            height: logoSize * 1.6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0xFF1D4ED8), Color(0x001D4ED8)],
                                stops: [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Logo: scale entry + breath pulse stacked.
                        Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale:
                                _logoScale.value *
                                (entryComplete ? breathScale : 1.0),
                            child: Image.asset(
                              SplashConstants.iconAsset,
                              width: logoSize,
                              height: logoSize,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Wordmark ───────────────────────────────────────────
                  Transform.translate(
                    offset: Offset(0, _wordmarkOffset.value),
                    child: Opacity(
                      opacity: _wordmarkOpacity.value,
                      child: Text(
                        SplashConstants.wordmark,
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
