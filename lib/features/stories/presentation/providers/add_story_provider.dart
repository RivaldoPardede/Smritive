import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/story_repository.dart';

enum AddStoryStatus { idle, loading, success, error }

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
  bool _photoOversize = false;

  // ── Location state (paid variant only) ────────────────────────────────────
  double? _selectedLat;
  double? _selectedLon;

  // ── Getters ───────────────────────────────────────────────────────────────

  AddStoryStatus get status => _status;
  XFile? get selectedImage => _selectedImage;
  String? get errorMessage => _errorMessage;
  bool get photoOversize => _photoOversize;
  bool get isLoading => _status == AddStoryStatus.loading;
  bool get isSuccess => _status == AddStoryStatus.success;
  double? get selectedLat => _selectedLat;
  double? get selectedLon => _selectedLon;
  bool get hasLocation => _selectedLat != null && _selectedLon != null;

  bool get canSubmit =>
      _selectedImage != null && _status != AddStoryStatus.loading;

  // ── Image ─────────────────────────────────────────────────────────────────

  /// Picks an image from [source]. Validates 1 MB limit.
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

  // ── Location ──────────────────────────────────────────────────────────────

  /// Sets the chosen location coordinates (paid variant only).
  void setLocation(double lat, double lon) {
    _selectedLat = lat;
    _selectedLon = lon;
    notifyListeners();
  }

  /// Clears the selected location.
  void clearLocation() {
    _selectedLat = null;
    _selectedLon = null;
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// Uploads the story with optional location coordinates.
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
        lat: _selectedLat,
        lon: _selectedLon,
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
