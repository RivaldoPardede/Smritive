import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/story_repository.dart';

enum AddStoryStatus { idle, loading, success, error }

/// Maximum allowed file size: 1 MB (from dicoding-api-docs.md).
const int _maxPhotoBytes = 1048576;

/// Drives the Add Story screen.
///
/// Lifecycle: scoped to the AddStoryPage route.
class AddStoryProvider extends ChangeNotifier {
  AddStoryProvider({
    required StoryRepository repository,
    required AuthProvider authProvider,
  })  : _repository = repository,
        _authProvider = authProvider;

  final StoryRepository _repository;
  final AuthProvider _authProvider;
  final ImagePicker _picker = ImagePicker();

  AddStoryStatus _status = AddStoryStatus.idle;
  XFile? _selectedImage;
  String? _errorMessage;

  /// True when the last picked image exceeded the 1 MB limit.
  /// The UI reads this flag, shows the localized SnackBar, then calls [clearOversizeFlag].
  bool _photoOversize = false;

  AddStoryStatus get status => _status;
  XFile? get selectedImage => _selectedImage;
  String? get errorMessage => _errorMessage;
  bool get photoOversize => _photoOversize;
  bool get isLoading => _status == AddStoryStatus.loading;
  bool get isSuccess => _status == AddStoryStatus.success;

  bool get canSubmit =>
      _selectedImage != null && _status != AddStoryStatus.loading;

  // ---------------------------------------------------------------- image

  /// Picks an image from [source]. Validates 1 MB limit.
  /// Sets [photoOversize] if file is too large — caller must show SnackBar
  /// using [AppLocalizations.error_photo_too_large] then call [clearOversizeFlag].
  Future<void> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return;

    final bytes = await file.length();
    if (bytes > _maxPhotoBytes) {
      _photoOversize = true;
      _selectedImage = null;
      notifyListeners();
      return;
    }

    _selectedImage = file;
    _photoOversize = false;
    notifyListeners();
  }

  void clearOversizeFlag() {
    _photoOversize = false;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // --------------------------------------------------------------- submit

  /// Uploads the story. On success sets [status] to [AddStoryStatus.success].
  Future<void> submit({required String description}) async {
    if (_selectedImage == null) return;

    _status = AddStoryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = _authProvider.token ?? '';
      final photoBytes = await File(_selectedImage!.path).readAsBytes();
      final result = await _repository.addStory(
        token: token,
        description: description,
        photoBytes: photoBytes,
        photoFilename: _selectedImage!.name,
      );
      if (result['error'] == true) {
        throw Exception(result['message'] as String? ?? 'Upload failed');
      }
      _status = AddStoryStatus.success;
    } catch (e) {
      _status = AddStoryStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }
}
