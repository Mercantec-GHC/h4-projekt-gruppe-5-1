import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_homepage.dart';
import '../api.dart';
import '../main.dart';

class AdminRegisterPage extends StatefulWidget {

  @override
  AdminRegisterPageState createState() => AdminRegisterPageState();
}

class AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool passwordMatch = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lav udlejer bruger'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                    labelText: 'Navn',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Brugernavn',
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
                        labelText: 'Bekræft Password',
                        labelStyle: TextStyle(
                          color: passwordMatch
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.red,
                        )),
                    obscureText: true,
                  )),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Telefon nummer',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    passwordMatch =
                        passwordController.text == confirmPasswordController.text;
                  });

                  if (passwordMatch) {
                    String name = nameController.text;
                    String username = usernameController.text;
                    String email = emailController.text;
                    String password = passwordController.text;
                    String phoneNumber = phoneNumberController.text;

                    await appState.udlejerRegister(
                        email, password, name, username, phoneNumber);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                  }
                },
                icon: Icon(Icons.login),
                label: Text('Lav bruger'),
              ),
            ],
          ),
        ), 
      ),
    );
  }
}
