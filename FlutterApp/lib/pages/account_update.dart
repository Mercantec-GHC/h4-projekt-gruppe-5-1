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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
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
                labelText: 'Phone number',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              String username = usernameController.text;
              String email = emailController.text;
              String phoneNumber = phoneNumberController.text;

              await appState.updateUserAccount(username, email, phoneNumber);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Passwords do not match')),
              );
            },
            icon: Icon(Icons.update),
            label: Text('Update account'),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onUpdate,
              icon: Icon(Icons.person),
              label: Text('Change password'),
            ),
          )
        ],
      ),
    ));
  }
}
