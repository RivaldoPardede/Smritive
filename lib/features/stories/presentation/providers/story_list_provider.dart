import 'package:flutter/foundation.dart';

import '../../data/story_repository.dart';
import '../../domain/story.dart';

enum StoryListStatus { idle, loading, loaded, error }

/// Manages the paginated story list.
///
/// - [fetch] loads page 1 and replaces the list (initial load + pull-to-refresh).
/// - [loadMore] appends subsequent pages; guards against double-calls and end-of-list.
class StoryListProvider extends ChangeNotifier {
  StoryListProvider({
    required StoryRepository repository,
    required String token,
    int pageSize = 10,
  })  : _repository = repository,
        _token = token,
        _pageSize = pageSize;

  final StoryRepository _repository;
  final String _token;
  final int _pageSize;

  // ── Primary state ──────────────────────────────────────────────────────────

  StoryListStatus _status = StoryListStatus.idle;
  List<Story> _stories = [];
  String? _errorMessage;

  // ── Pagination state ───────────────────────────────────────────────────────

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _loadMoreError;

  // ── Getters ────────────────────────────────────────────────────────────────

  StoryListStatus get status => _status;
  List<Story> get stories => List.unmodifiable(_stories);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StoryListStatus.loading;
  bool get hasError => _status == StoryListStatus.error;
  bool get isEmpty => _status == StoryListStatus.loaded && _stories.isEmpty;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get loadMoreError => _loadMoreError;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Loads page 1 from scratch. Replaces any existing list.
  /// Called on initial load and pull-to-refresh.
  Future<void> fetch() async {
    _status = StoryListStatus.loading;
    _errorMessage = null;
    _stories = [];
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _repository.getStories(
        token: _token,
        page: 1,
        size: _pageSize,
      );
      _stories = _dedup(page);
      _currentPage = 1;
      _hasMore = page.length >= _pageSize;
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

  /// Alias for [fetch] — used by pull-to-refresh.
  Future<void> refresh() => fetch();

  /// Appends the next page. No-op if already loading or no more pages exist.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status != StoryListStatus.loaded) {
      return;
    }

    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final page = await _repository.getStories(
        token: _token,
        page: nextPage,
        size: _pageSize,
      );
      _stories = _dedup([..._stories, ...page]);
      _currentPage = nextPage;
      _hasMore = page.length >= _pageSize;
    } on StoryException catch (e) {
      _loadMoreError = e.message;
    } catch (_) {
      _loadMoreError = 'Failed to load more stories.';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Removes duplicate stories by ID (guards against API returning overlapping pages).
  List<Story> _dedup(List<Story> raw) {
    final seen = <String>{};
    return raw.where((s) => seen.add(s.id)).toList();
  }
}
