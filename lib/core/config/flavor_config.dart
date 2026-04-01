/// Build-flavor configuration.
///
/// Read at compile time from the Dart environment variable `FLAVOR`.
///
/// Run commands:
///   flutter run --dart-define=FLAVOR=free    (default)
///   flutter run --dart-define=FLAVOR=paid
///   flutter build apk --dart-define=FLAVOR=paid
///
/// The free variant cannot add a location to new stories.
/// The paid variant can add a location to new stories.
class FlavorConfig {
  FlavorConfig._();

  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'free',
  );

  /// Whether the current build is the free variant.
  static bool get isFree => _flavor == 'free';

  /// Whether the current build is the paid variant.
  static bool get isPaid => _flavor == 'paid';

  /// Display name of the current flavor for debugging.
  static String get name => _flavor;
}
