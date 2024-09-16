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
  List<AllUsersData> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      String? token = await Provider.of<MyAppState>(context, listen: false)
          .apiService
          .secureStorage
          .read(key: 'token');
      if (token == null) {
        throw Exception("User ID not found in secure storage");
      }
      final response = await http
          .get(Uri.parse('https://h4-g5.onrender.com/api/Users'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = data.map((item) => AllUsersData.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load brugere: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception in _fetchUsers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> delete(String id) async {
    try {
      String? token = await Provider.of<MyAppState>(context, listen: false)
          .apiService
          .secureStorage
          .read(key: 'token');
      if (token == null) {
        throw Exception("User ID not found in secure storage");
      }
      final response = await http
          .delete(Uri.parse('https://h4-g5.onrender.com/api/Users/$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('bruger slettet')),
        );
        setState(() {
          _users.removeWhere((user) => user.id == id);
        });
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('der skete en fejl')),
        );
        throw Exception('kunne ikke slette brugere: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('der skete en fejl')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alle brugere'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: [
                                Text(user.name),
                                Text(user.email),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await delete(user.id);
                              },
                              icon: Icon(Icons.delete),
                              label: Text('slet'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
