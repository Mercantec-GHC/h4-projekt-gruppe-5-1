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
                  labelText: 'Nuværende Password',
                ),
                obscureText: true,
              )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nyt Password',
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
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                passwordMatch =
                    passwordController.text == confirmPasswordController.text;
              });

              if (passwordMatch) {
                String password = passwordController.text;
                String oldpassword = oldPasswordController.text;
                try {
                  // Send det indtastede navn videre til opdateringsmetoden
                  await appState.updateUserPassword(password, oldpassword);

                  // Hvis opdateringen lykkes, vis en SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password opdateret')),
                  );
                } catch (e) {
                  print('Fejl ved opdatering: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fejl ved opdatering')),
                  );
                }
                await appState.updateUserPassword(password, oldpassword);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwordne er ikke ens')),
                );
              }
            },
            icon: Icon(Icons.password),
            label: Text('Skift password'),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onUpdate,
              icon: Icon(Icons.person),
              label: Text('Opdater bruger'),
            ),
          )
        ],
      ),
    ));
  }
}
