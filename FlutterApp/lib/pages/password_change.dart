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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordMatch = true;
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
                controller: oldPasswordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Old Password',
                ),
                obscureText: true,
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New Password',
                ),
                obscureText: true,
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: passwordMatch
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : Colors.red,
                    )),
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(
                      color: passwordMatch
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : Colors.red,
                    )),
                obscureText: true,
              )),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                passwordMatch =
                    passwordController.text == confirmPasswordController.text;
              });

              if (passwordMatch) {
                String password = passwordController.text;
                String oldpassword = oldPasswordController.text;

                await appState.updateUserPassword(password, oldpassword);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
            icon: Icon(Icons.password),
            label: Text('Change password'),
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
