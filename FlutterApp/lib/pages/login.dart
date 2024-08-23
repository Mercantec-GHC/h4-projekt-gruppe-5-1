import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final VoidCallback onCreateUser;

  LoginPage({required this.onCreateUser});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                floatingLabelStyle: Theme.of(context).textTheme.titleLarge,
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20), 
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
            padding: const EdgeInsets.all(20), 
            child: ElevatedButton.icon(
                onPressed: () async {
                  await appState.login(emailController.text, passwordController.text);
                },
                icon: Icon(Icons.login),
                label: Text('Login'),
              ),
          ),
          ElevatedButton.icon(
                onPressed: onCreateUser,
                icon: Icon(Icons.create),
                label: Text('Create User'),
              ),
        ],
      ),

    );

  }
}