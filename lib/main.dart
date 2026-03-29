import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Both providers need async init — run in parallel for speed.
  final results = await Future.wait([
    AuthProvider.create(),
    LocaleProvider.create(),
  ]);

  final authProvider = results[0] as AuthProvider;
  final localeProvider = results[1] as LocaleProvider;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: SmritiveApp(authProvider: authProvider),
    ),
  );
}

/// Root widget. Reads [LocaleProvider] so locale changes rebuild [MaterialApp].
class SmritiveApp extends StatefulWidget {
  const SmritiveApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<SmritiveApp> createState() => _SmritiveAppState();
}

class _SmritiveAppState extends State<SmritiveApp> {
  late final _router = createRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    // Watch LocaleProvider so MaterialApp rebuilds on language change.
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
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
    );
  }
}
