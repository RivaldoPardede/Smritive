import 'package:json_annotation/json_annotation.dart';

part 'story.g.dart';

/// Story domain model — fields mapped directly from the Dicoding API response.
@JsonSerializable()
class Story {
  const Story({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final String createdAt;
  final double? lat;
  final double? lon;

  /// Whether this story has valid map coordinates.
  bool get hasLocation => lat != null && lon != null;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}
