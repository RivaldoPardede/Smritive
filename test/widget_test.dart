import 'package:flutter_test/flutter_test.dart';

import 'package:smritive/features/auth/domain/login_result.dart';
import 'package:smritive/features/stories/domain/story.dart';

void main() {
  group('LoginResult', () {
    test('fromJson maps all fields correctly', () {
      final json = {'userId': 'user-123', 'name': 'Riva', 'token': 'tok-abc'};
      final result = LoginResult.fromJson(json);
      expect(result.userId, 'user-123');
      expect(result.name, 'Riva');
      expect(result.token, 'tok-abc');
    });
  });

  group('Story', () {
    test('fromJson maps required fields', () {
      final json = {
        'id': 'story-1',
        'name': 'Author',
        'description': 'A lovely description',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'lat': null,
        'lon': null,
      };
      final story = Story.fromJson(json);
      expect(story.id, 'story-1');
      expect(story.name, 'Author');
      expect(story.description, 'A lovely description');
      expect(story.photoUrl, 'https://example.com/photo.jpg');
      expect(story.lat, isNull);
      expect(story.lon, isNull);
    });

    test('fromJson maps optional lat/lon', () {
      final json = {
        'id': 'story-2',
        'name': 'Author',
        'description': 'With location',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'lat': -6.2,
        'lon': 106.8,
      };
      final story = Story.fromJson(json);
      expect(story.lat, closeTo(-6.2, 0.001));
      expect(story.lon, closeTo(106.8, 0.001));
    });
  });
}
