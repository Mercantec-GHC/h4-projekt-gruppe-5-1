import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' as main;

class PasswordChanger extends StatefulWidget {
  final VoidCallback onUpdate;
  PasswordChanger({required this.onUpdate});
  @override
  PasswordChangerState createState() => PasswordChangerState();
}

class PasswordChangerState extends State<PasswordChanger> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<main.MyAppState>();
    //var storage = main.storage;

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Old Password',
                ),
                obscureText: true,
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New Password',
                ),
                obscureText: true,
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              )),
          ElevatedButton.icon(
            onPressed: () {
              appState.toggleFavorite();
            },
            icon: Icon(Icons.password),
            label: Text('Save login informations'),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onUpdate,
              icon: Icon(Icons.person),
              label: Text('Update User'),
            ),
          )
        ],
      ),
    ));
  }
}
