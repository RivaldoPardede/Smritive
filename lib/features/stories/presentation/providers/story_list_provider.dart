import 'package:flutter/foundation.dart';

import '../../data/story_repository.dart';
import '../../domain/story.dart';

enum StoryListStatus { idle, loading, loaded, error }

/// Manages the story list fetched from /stories.
///
/// Exposes [refresh] so it can be called after a successful upload (Phase 3).
class StoryListProvider extends ChangeNotifier {
  StoryListProvider({
    required StoryRepository repository,
    required String token,
  })  : _repository = repository,
        _token = token;

  final StoryRepository _repository;
  final String _token;

  StoryListStatus _status = StoryListStatus.idle;
  List<Story> _stories = [];
  String? _errorMessage;

  StoryListStatus get status => _status;
  List<Story> get stories => _stories;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StoryListStatus.loading;
  bool get hasError => _status == StoryListStatus.error;
  bool get isEmpty =>
      _status == StoryListStatus.loaded && _stories.isEmpty;

  /// Fetches page 1. Call on first load and after successful story upload.
  Future<void> fetch() async {
    _status = StoryListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _stories = await _repository.getStories(token: _token, page: 1);
      _status = StoryListStatus.loaded;
    } on StoryException catch (e) {
      _status = StoryListStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = StoryListStatus.error;
      _errorMessage = 'An unexpected error occurred.';
    }

    notifyListeners();
  }

  /// Alias for [fetch] — used by the pull-to-refresh and "Refresh to update" link.
  Future<void> refresh() => fetch();
}
