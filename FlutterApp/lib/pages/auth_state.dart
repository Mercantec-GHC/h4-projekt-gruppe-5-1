import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

bool _isLoggedIn = false;

bool get loggedIn => _isLoggedIn;

Future<LoginInfo> loginPost(String email, String password) async {
  final response = await http.post(
    Uri.parse('https://localhost:7014/api/Users/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    _isLoggedIn = true;
    return LoginInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to login: $email ($password)');
  }
}

class LoginInfo {
  final String username;
  final String token;
  final int id;

  const LoginInfo({
    required this.username,
    required this.token,
    required this.id,
  });

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

class AuthState with ChangeNotifier {
  bool isLoggedIn = loggedIn;
  LoginInfo? loginInfo;

  Future<void> logIn(String email, String password) async {
    try {
      loginInfo = await loginPost(email, password);
      isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      // Handle login failure, maybe show a toast or error message
      print(e);
    }
  }

  void logOut() {
    isLoggedIn = false;
    notifyListeners();
  }
}
