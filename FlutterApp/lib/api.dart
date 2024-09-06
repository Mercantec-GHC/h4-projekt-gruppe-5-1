import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/user_info_model.dart';

bool _isLoggedIn = false;
bool get loggedIn => _isLoggedIn;

class ApiService {
  final String baseUrl;
  // Initialiser secure storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  ApiService({required this.baseUrl});

  Future<LoginInfo> loginUser(String email, String password) async {
    var uri = Uri.https(baseUrl, 'api/Users/login');
    final response = await http.post(
      uri,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      _isLoggedIn = true;
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      // Gem token i secure storage
      await secureStorage.write(key: 'token', value: data['token']);
      await secureStorage.write(key: 'id', value: data['id'].toString());
      await secureStorage.write(key: 'name', value: data['name']);
      await secureStorage.write(key: 'email', value: data['email']);
      await secureStorage.write(key: 'phoneNumber', value: data['phoneNumber']);
      await secureStorage.write(key: 'username', value: data['username']);
      await secureStorage.write(
          key: 'profilePictureURL', value: data['profilePictureURL']);
      await secureStorage.write(
          key: 'userType', value: data['userType'].toString());
      return LoginInfo.fromJson(data);
    } else {
      throw Exception(
          'Failed to login: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<void> logoutUser() async {
    // Slet token fra secure storage
    await secureStorage.delete(key: 'token');
    _isLoggedIn = false;
  }

  Future<Map<String, dynamic>> getUser() async {
    var id = await secureStorage.read(key: 'id');
    var name = await secureStorage.read(key: 'name');
    var email = await secureStorage.read(key: 'email');
    var phoneNumber = await secureStorage.read(key: 'phoneNumber');
    var username = await secureStorage.read(key: 'username');
    var userType = await secureStorage.read(key: 'userType');
    var profilePictureURL = await secureStorage.read(key: 'profilePictureURL');
    var userData = {
      "id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "userType": userType,
      "ProfilePictureURL": profilePictureURL,
    };
    return userData;
  }

  //String img,
  Future<String> updateUser(String name) async {
    var token = await secureStorage.read(key: 'token');
    String id = await secureStorage.read(key: 'id') as String;
    var uri = Uri.https(baseUrl, 'api/Users/$id');
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        //'photo': img
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to update User: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> updateAccount(
    String email,
    String username,
    String phoneNumber,
  ) async {
    var token = await secureStorage.read(key: 'token');
    String id = await secureStorage.read(key: 'id') as String;
    var uri = Uri.https(baseUrl, 'api/Users/account/$id');
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
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

  Future<Map<String, dynamic>> updatePassword(
    String password,
    String oldPassword,
  ) async {
    var token = await secureStorage.read(key: 'token');
    String id = await secureStorage.read(key: 'id') as String;
    var uri = Uri.https(baseUrl, 'api/Users/password/$id');
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'password': password,
        'oldPassword': oldPassword,
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
    var uri = Uri.https(baseUrl, 'api/Users');
    final response = await http.post(
      uri,
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
