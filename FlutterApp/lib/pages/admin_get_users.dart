import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sks_booking/models/all_users_model.dart';
import '../main.dart';

class GetAllUsers extends StatefulWidget {
  @override
  GetAllUsersState createState() => GetAllUsersState();
}

class GetAllUsersState extends State<GetAllUsers> {
  late Future<List<AllUsersData>> _brugereFuture;

  @override
  void initState() {
    super.initState();
    _brugereFuture = _fetchUsers();
  }

  Future<List<AllUsersData>> _fetchUsers() async {
    try {
      String? token = await Provider.of<MyAppState>(context, listen: false)
          .apiService
          .secureStorage
          .read(key: 'token');
      if (token == null) {
        throw Exception("User ID not found in secure storage");
      }
      final response = await http
          .get(Uri.parse('https://localhost:7014/api/Users'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed data: $data');

        final users = data.map((item) => AllUsersData.fromJson(item)).toList();
        print('Parsed users: $users');
        return users;
      } else {
        throw Exception('Failed to load brugere: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception in _fetchUsers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alle brugere'),
      ),
      body: FutureBuilder<List<AllUsersData>>(
        future: _brugereFuture,
        builder: (context, snapshot) {
          print('Snapshot state: ${snapshot.connectionState}');
          print('Snapshot has data: ${snapshot.hasData}');
          print('Snapshot data length: ${snapshot.data?.length}');
          print('Snapshot data: ${snapshot.data}');
          print('Snapshot error: ${snapshot.error}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(user.name),
                    Text(user.email),
                    ElevatedButton.icon(
                      onPressed: () {
                        print(user.id);
                      },
                      icon: Icon(Icons.delete),
                      label: Text('slet'),
                    ),
                  ],
                );
              },
            );
          } else {
            return Center(child: Text('No users found'));
          }
        },
      ),
    );
  }
}
