import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/user_info_model.dart';

//import 'main.dart';
bool _isLoggedIn = false;

bool get loggedIn => _isLoggedIn;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<LoginInfo> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/login'),
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
      throw Exception(
          'Failed to login: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> updateUser(int id, String name, String email,
      String phoneNumber, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to update User: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> createUser(String name, String email,
      String password, String phoneNumber, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'username': username,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to create user: ${response.reasonPhrase} (${response.statusCode})');
    }
  }
}
