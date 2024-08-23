import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      print('success');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> createUser(String name, String email, String password, String phoneNumber, String username) async {
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
      throw Exception('Failed to create user: ${response.reasonPhrase} (${response.statusCode})');
    }
  }
}
