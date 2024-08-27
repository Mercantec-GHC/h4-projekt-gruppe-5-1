class LoginInfo {
  final String username;
  final String token;
  final int id;

  const LoginInfo({
    required this.username,
    required this.token,
    required this.id,
  });

  //storage.write(key: 'token', value: token);
  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'username': String username,
        'token': String token,
        'id': int id,
      } =>
        LoginInfo(
          username: username,
          token: token,
          id: id,
        ),
      _ => throw const FormatException('Failed to load user.'),
    };
  }
}
