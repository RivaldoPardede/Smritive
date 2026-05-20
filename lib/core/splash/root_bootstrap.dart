import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../network/api_service.dart';
import '../providers/locale_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import 'animated_splash_screen.dart';
import 'splash_constants.dart';

/// Owns the bootstrap lifecycle and decides when the animated splash should
/// hand over to the real app tree.
///
/// Lifecycle:
///   t=0       Native SplashScreen API hands off; this widget mounts.
///             [AnimatedSplashScreen] starts its entry animation.
///   t=concur  Auth + Locale providers hydrate from SharedPreferences in
///             parallel; a min-hold timer also runs.
///   t=both    Once providers are ready AND min-hold elapsed, [_ready] is
///             set to true. The splash starts its fade-out.
///   t=after   Splash's onDismissed swaps in [_AppRoot], which is the real
///             MaterialApp.router driven by the providers.
///
/// A hard [SplashConstants.maxHold] cap guarantees the splash cannot stall
/// forever even if SharedPreferences hangs.
class RootBootstrap extends StatefulWidget {
  const RootBootstrap({super.key});

  @override
  State<RootBootstrap> createState() => _RootBootstrapState();
}

class _RootBootstrapState extends State<RootBootstrap> {
  // Bootstrap result (null until ready).
  AuthProvider? _auth;
  LocaleProvider? _locale;
  Object? _bootstrapError;

  bool _ready = false; // splash has been told to start fading out
  bool _showApp = false; // splash fade-out finished; show real app tree

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Min-hold guarantees the splash is visible long enough to read the brand,
    // even on a fresh boot where SharedPreferences resolves in <100 ms.
    final minHold = Future<void>.delayed(SplashConstants.minHold);

    // Provider creation runs in parallel for speed. Wrap in try so any
    // failure surfaces as a recoverable error rather than a black screen.
    Future<List<Object>> providers() async {
      return Future.wait<Object>([
        AuthProvider.create(),
        LocaleProvider.create(),
      ]);
    }

    // Hard cap: never let the splash exceed maxHold.
    final cap = Future<void>.delayed(SplashConstants.maxHold);

    try {
      final results = await Future.any<List<Object>?>([
        providers().then<List<Object>?>((v) => v),
        cap.then<List<Object>?>((_) => null),
      ]);

      // Wait for min-hold regardless (or no-op if already past).
      await minHold;

      if (results == null) {
        // Hit the cap. Surface as an error UI (rare path).
        if (!mounted) return;
        setState(() {
          _bootstrapError = TimeoutException(
            'Startup is taking longer than usual.',
          );
          _ready = true;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _auth = results[0] as AuthProvider;
        _locale = results[1] as LocaleProvider;
        _ready = true;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _bootstrapError = err;
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The splash always covers everything until _showApp flips. Once it does,
    // we render the real app tree (or a tiny error scaffold).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (_showApp)
            _bootstrapError != null || _auth == null || _locale == null
                ? _ErrorScaffold(error: _bootstrapError ?? 'Unknown error')
                : _AppRoot(authProvider: _auth!, localeProvider: _locale!),
          if (!_showApp)
            AnimatedSplashScreen(
              readyToDismiss: _ready,
              onDismissed: () {
                if (!mounted) return;
                setState(() => _showApp = true);
              },
            ),
        ],
      ),
    );
  }
}

/// Real app tree. Mirrors the original `SmritiveApp` from main.dart, but
/// receives already-hydrated providers from [RootBootstrap].
class _AppRoot extends StatefulWidget {
  const _AppRoot({required this.authProvider, required this.localeProvider});

  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final _router = createRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: widget.authProvider),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: widget.localeProvider,
        ),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleProvider>().locale;
          return MaterialApp.router(
            title: 'Smritive',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('id')],
          );
        },
      ),
    );
  }
}

/// Minimal error UI shown if bootstrap fails or times out.
/// Avoids depending on AppLocalizations (which itself may have failed to load).
class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: SplashConstants.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not start Smritive.\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
