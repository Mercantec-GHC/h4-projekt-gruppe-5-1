import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart' as api;
import '../main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onCreateUser;

  const LoginPage({super.key, required this.onCreateUser});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final VoidCallback onCreateUser;

  @override
  void initState() {
    super.initState();
    onCreateUser = widget.onCreateUser;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
              ),
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
                  )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String email = emailController.text;
                    String password = passwordController.text;
                    await appState.login(email, password);

                    if (api.loggedIn) {
                      // Navigate to another page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } else {
                      // Show error message or handle login failure
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Login failed. Please try again.')),
                      );
                    }
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
        )));
  }
}
