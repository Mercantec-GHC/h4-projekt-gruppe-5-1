import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_homepage.dart';

import '../main.dart';

class MakeAdsPage extends StatefulWidget {

  @override
  MakeAdsPageState createState() => MakeAdsPageState();
}

class MakeAdsPageState extends State<MakeAdsPage> {
  final TextEditingController titleController = TextEditingController();
  // final TextEditingController usernameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController imageController =
      TextEditingController();
  // final TextEditingController phoneNumberController = TextEditingController();

  bool passwordMatch = true;

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lav Reklame'),
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
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Titel',
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: TextFormField(
              //     controller: usernameController,
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'Username',
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Beskrivelse',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: linkController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Link',
                    ),
                    obscureText: true,
                  )),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Billede',
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  print('Reklame lavet');
                },
                icon: Icon(Icons.login),
                label: Text('Lav Reklame'),
              ),
            ],
          ),
        ), 
      ),
    );
  }
}
