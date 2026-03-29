/// Typed result returned after a successful login.
/// Maps directly to the `loginResult` object in the API response.
class LoginResult {
  const LoginResult({
    required this.userId,
    required this.name,
    required this.token,
  });

  final String userId;
  final String name;
  final String token;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      userId: json['userId'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
    );
  }
}
