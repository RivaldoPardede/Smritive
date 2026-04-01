import 'package:json_annotation/json_annotation.dart';

part 'login_result.g.dart';

/// Typed result returned after a successful login.
/// Maps directly to the `loginResult` object in the API response.
@JsonSerializable()
class LoginResult {
  const LoginResult({
    required this.userId,
    required this.name,
    required this.token,
  });

  final String userId;
  final String name;
  final String token;

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
