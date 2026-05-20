import 'package:flutter/material.dart';

import 'core/splash/root_bootstrap.dart';

/// Entry point. Kept intentionally minimal: all bootstrap orchestration lives
/// inside [RootBootstrap], which mounts the animated splash first and only
/// hands over to the real app tree once the providers are ready.
///
/// The native SplashScreen API (configured in
/// android/app/src/main/res/values-v31/styles.xml and the legacy
/// drawable/launch_background.xml) handles t<0; this Flutter side handles
/// t>=0 with a brand-coloured animated splash.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RootBootstrap());
}
