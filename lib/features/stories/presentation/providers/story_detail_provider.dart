import 'package:flutter/foundation.dart';

import '../../data/story_repository.dart';
import '../../domain/story.dart';

enum StoryDetailStatus { idle, loading, loaded, error }

/// Manages a single story's data for the detail screen.
class StoryDetailProvider extends ChangeNotifier {
  StoryDetailProvider({
    required StoryRepository repository,
    required String token,
  }) : _repository = repository,
       _token = token;

  final StoryRepository _repository;
  final String _token;

  StoryDetailStatus _status = StoryDetailStatus.idle;
  Story? _story;
  String? _errorMessage;

  StoryDetailStatus get status => _status;
  Story? get story => _story;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StoryDetailStatus.loading;
  bool get hasError => _status == StoryDetailStatus.error;

  Future<void> fetch(String id) async {
    _status = StoryDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _story = await _repository.getStoryDetail(token: _token, id: id);
      _status = StoryDetailStatus.loaded;
    } on StoryException catch (e) {
      _status = StoryDetailStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = StoryDetailStatus.error;
      _errorMessage = 'An unexpected error occurred.';
    }

    notifyListeners();
  }
}
