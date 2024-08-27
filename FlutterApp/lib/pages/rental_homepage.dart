import '../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RentalHomepage extends StatelessWidget {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(217, 217, 217, 100), // Background color for the container
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}