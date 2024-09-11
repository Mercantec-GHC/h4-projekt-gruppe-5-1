import 'package:flutter/material.dart';

class AllUsersData extends StatelessWidget {
  final String id;
  final String name;
  final String email;

  AllUsersData({required this.id, required this.name, required this.email});

  AllUsersData.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'] as String,
        email = json['email'] as String;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
