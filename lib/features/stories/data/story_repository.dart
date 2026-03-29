import '../../../core/network/api_service.dart';
import '../domain/story.dart';

/// Translates raw API responses into typed [Story] objects or throws [StoryException].
class StoryRepository {
  const StoryRepository(this._api);

  final ApiService _api;

  /// Fetches page [page] of stories. Returns an empty list if the API returns
  /// an empty listStory array.
  Future<List<Story>> getStories({
    required String token,
    int page = 1,
    int size = 20,
  }) async {
    final body = await _api.getStories(token: token, page: page, size: size);
    if (body['error'] == true) {
      throw StoryException(
        body['message'] as String? ?? 'Failed to load stories',
      );
    }
    final list = body['listStory'] as List<dynamic>;
    return list.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches a single story by [id].
  Future<Story> getStoryDetail({
    required String token,
    required String id,
  }) async {
    final body = await _api.getStoryDetail(token: token, id: id);
    if (body['error'] == true) {
      throw StoryException(
        body['message'] as String? ?? 'Failed to load story',
      );
    }
    return Story.fromJson(body['story'] as Map<String, dynamic>);
  }

  /// Uploads a new story via multipart POST /stories.
  /// Returns the raw response map; the `error` field indicates failure.
  Future<Map<String, dynamic>> addStory({
    required String token,
    required String description,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    return _api.addStory(
      token: token,
      description: description,
      photoBytes: photoBytes,
      photoFilename: photoFilename,
    );
  }
}

/// Thrown when the stories API returns an error response.
class StoryException implements Exception {
  const StoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
