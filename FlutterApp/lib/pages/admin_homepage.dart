import '../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  print('hello');
                },
                icon: Icon(Icons.create),
                label: Text('Create User'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Troll');
                },
                icon: Icon(Icons.create),
                label: Text('See Users'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Tor');
                },
                icon: Icon(Icons.create),
                label: Text('See reviews'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Loke');
                },
                icon: Icon(Icons.create),
                label: Text('See appartments'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Odin');
                },
                icon: Icon(Icons.create),
                label: Text('See adds'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Frøya');
                },
                icon: Icon(Icons.create),
                label: Text('Make adds'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}