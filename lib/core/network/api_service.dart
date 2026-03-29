import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL for the Dicoding Story API (from dicoding-api-docs.md).
const String _baseUrl = 'https://story-api.dicoding.dev/v1';

/// Thin wrapper around [http.Client] that provides typed results.
///
/// Every method returns a [Map] parsed from the JSON response body.
/// Callers must check the `error` field in the map before using `data`.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ------------------------------------------------------------------ auth

  /// POST /register
  /// Body: { name, email, password }
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _decode(response);
  }

  /// POST /login
  /// Body: { email, password }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(response);
  }

  // ---------------------------------------------------------------- stories

  /// GET /stories
  /// Headers: Authorization: Bearer &lt;token&gt;
  Future<Map<String, dynamic>> getStories({
    required String token,
    int page = 1,
    int size = 20,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/stories',
    ).replace(queryParameters: {'page': '$page', 'size': '$size'});
    final response = await _client.get(uri, headers: _authHeader(token));
    return _decode(response);
  }

  /// GET /stories/:id
  Future<Map<String, dynamic>> getStoryDetail({
    required String token,
    required String id,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/stories/$id'),
      headers: _authHeader(token),
    );
    return _decode(response);
  }

  /// POST /stories — multipart/form-data
  /// Fields: description (string), photo (file ≤ 1 MB)
  Future<Map<String, dynamic>> addStory({
    required String token,
    required String description,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    final uri = Uri.parse('$_baseUrl/stories');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeader(token))
      ..fields['description'] = description
      ..files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: photoFilename,
        ),
      );
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  // ---------------------------------------------------------------- helpers

  Map<String, String> _authHeader(String token) => {
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body;
  }
}
