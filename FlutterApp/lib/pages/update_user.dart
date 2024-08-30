import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' as main;

class UpdatePage extends StatefulWidget {
  final VoidCallback password;

  UpdatePage({required this.password});
  @override
  UpdatePageState createState() => UpdatePageState();
}

class UpdatePageState extends State<UpdatePage> {
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
                labelText: 'Name',
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                ),
              )),
          ElevatedButton.icon(
            onPressed: () {
              appState.toggleFavorite();
            },
            icon: Icon(Icons.login),
            label: Text('Save changes'),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: widget.password,
              icon: Icon(Icons.password),
              label: Text('Change account informations'),
            ),
          ),
        ],
      ),
    ));
  }
}
