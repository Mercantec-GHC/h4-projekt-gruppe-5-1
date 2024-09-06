import 'package:sks_booking/pages/admin_create_user.dart';
import 'package:sks_booking/pages/make_ads.dart';

import '../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => AdminRegisterPage()),
                  );
                },
                icon: Icon(Icons.create),
                label: Text('Lav Udlejer Bruger'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Troll');
                },
                icon: Icon(Icons.create),
                label: Text('Se brugere'),
              ),
              SizedBox(height: 10),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     print('Tor');
              //   },
              //   icon: Icon(Icons.create),
              //   label: Text('See reviews'),
              // ),
              // SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Loke');
                },
                icon: Icon(Icons.create),
                label: Text('Se Lejligheder'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  print('Odin');
                },
                icon: Icon(Icons.create),
                label: Text('Se Reklamer'),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => MakeAdsPage()),
                  );
                },
                icon: Icon(Icons.create),
                label: Text('Lav Reklamer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}