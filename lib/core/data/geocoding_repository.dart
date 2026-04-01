import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches a human-readable address for a coordinate pair using the
/// OpenStreetMap Nominatim reverse-geocoding API.
///
/// Nominatim is free and requires no API key.
/// Rate limit: 1 request/second. For a submission app this is fine.
class GeocodingRepository {
  GeocodingRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Returns a formatted address string for [lat]/[lon].
  /// Throws [GeocodingException] on network or API errors.
  Future<String> getAddress(double lat, double lon) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
    });

    final response = await _client.get(
      uri,
      headers: {
        // Nominatim requires a valid User-Agent per their usage policy.
        'User-Agent': 'Smritive/1.0 (Dicoding Submission)',
        'Accept-Language': 'id,en',
      },
    );

    if (response.statusCode != 200) {
      throw GeocodingException(
        'Failed to fetch address (HTTP ${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final displayName = body['display_name'] as String?;
    if (displayName == null || displayName.isEmpty) {
      throw GeocodingException('No address found for this location.');
    }
    return displayName;
  }
}

/// Thrown when a reverse-geocoding request fails.
class GeocodingException implements Exception {
  const GeocodingException(this.message);
  final String message;

  @override
  String toString() => message;
}
