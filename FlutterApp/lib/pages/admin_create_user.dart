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
  final TextEditingController adminnameController = TextEditingController();
  final TextEditingController adminusernameController = TextEditingController();
  final TextEditingController adminemailController = TextEditingController();
  final TextEditingController adminpasswordController = TextEditingController();
  final TextEditingController adminconfirmPasswordController =
      TextEditingController();
  final TextEditingController adminphoneNumberController =
      TextEditingController();

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
                  controller: adminnameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Navn',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: adminusernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Brugernavn',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: adminemailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: adminpasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  )),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: adminconfirmPasswordController,
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
                  controller: adminphoneNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Telefon nummer',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    passwordMatch = adminpasswordController.text ==
                        adminconfirmPasswordController.text;
                  });

                  if (passwordMatch) {
                    String name = adminnameController.text;
                    String username = adminusernameController.text;
                    String email = adminemailController.text;
                    String password = adminpasswordController.text;
                    String phoneNumber = adminphoneNumberController.text;
                    int userType = 1;

                    await appState.register(
                        name, email, password, phoneNumber, username, userType);
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
