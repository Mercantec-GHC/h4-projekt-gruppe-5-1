import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLogin;

  RegisterPage({required this.onLogin});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool passwordMatch = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10), 
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10), 
            child: TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: passwordMatch ? Colors.grey : Colors.red,
                  )
                ),
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  color: passwordMatch ? Colors.grey : Colors.red,
                )
              ),
              obscureText: true,
            )
          ),
          ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    passwordMatch = passwordController.text == confirmPasswordController.text;
                  });

                  if (passwordMatch) {
                    String name = nameController.text;
                    String email = passwordController.text;
                    String password = passwordController.text;

                    await appState.register(name, email, password);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                  }
                },
                icon: Icon(Icons.login),
                label: Text('Create User'),
              ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onLogin,
              icon: Icon(Icons.login),
              label: Text('Log in'),
            ), 
          )
        ],
      ),

    );

  }
}