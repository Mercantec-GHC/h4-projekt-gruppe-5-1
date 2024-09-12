import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_input/image_input.dart';
import 'models/user_info_model.dart';

final dio = Dio();
bool _isLoggedIn = false;
bool get loggedIn => _isLoggedIn;

class ApiService {
  final String baseUrl;
  // Initialiser secure storage
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  ApiService({required this.baseUrl});

  Future<LoginInfo> loginUser(String email, String password) async {
    var uri = Uri.parse('$baseUrl/Users/login');
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
      print(data);
      await secureStorage.write(key: 'token', value: data['token']);
      await secureStorage.write(key: 'id', value: data['id'].toString());
      await secureStorage.write(key: 'name', value: data['name']);
      await secureStorage.write(key: 'email', value: data['email']);
      await secureStorage.write(key: 'phoneNumber', value: data['phoneNumber']);
      await secureStorage.write(key: 'username', value: data['username']);
      await secureStorage.write(key: 'biography', value: data['biography']);
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
    await secureStorage.delete(key: 'userType');
    _isLoggedIn = false;
  }

  Future<Map<String, dynamic>> getUser() async {
    var id = await secureStorage.read(key: 'id');
    var name = await secureStorage.read(key: 'name');
    var email = await secureStorage.read(key: 'email');
    var phoneNumber = await secureStorage.read(key: 'phoneNumber');
    var username = await secureStorage.read(key: 'username');
    var userType = await secureStorage.read(key: 'userType');
    var bio = await secureStorage.read(key: 'biography');
    var profilePictureURL = await secureStorage.read(key: 'profilePictureURL');
    var userData = {
      "id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "userType": userType,
      "biography": bio,
      "profilePictureURL": profilePictureURL,
    };
    return userData;
  }

  //String img,
  Future<dynamic> updateUser(String name, XFile? img, String? oldImg) async {
    var token = await secureStorage.read(key: 'token');
    String id = await secureStorage.read(key: 'id') as String;
    var uri = '$baseUrl/Users/$id';

    final formData = FormData.fromMap({
      'name': name,
      'ProfilePictureURL': oldImg,
      'ProfilePicture': await MultipartFile.fromFile(img!.path),
    });
    final response = await dio.put(
      uri,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(
          'Failed to update User: ${response.statusMessage} (${response.statusCode})');
    }
  }

  Future<String> updateUserBio(String bio) async {
    var token = await secureStorage.read(key: 'token');
    String id = await secureStorage.read(key: 'id') as String;
    var uri = Uri.parse('$baseUrl/Users/biografi/$id');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'biography': bio,
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
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
    var uri = Uri.parse('$baseUrl/Users/account/$id');
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
    var uri = Uri.parse('$baseUrl/Users/password/$id');
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
    var uri = '$baseUrl/Users';
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'username': username,
      'userType': 0,
    });
    final response = await dio.post(
      uri,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception(
          'Failed to create user: ${response.statusMessage} (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> createUdlejerUser(String name, String email,
      String password, String phoneNumber, String username) async {
    var uri = '$baseUrl/Users';
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'username': username,
      'userType': 1,
    });
    final response = await dio.post(
      uri,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );
    
    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception(
          'Failed to create user: ${response.statusMessage} (${response.statusCode})');
    }
  }
}
