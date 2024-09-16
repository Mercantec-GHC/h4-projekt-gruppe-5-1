import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_data_model.dart';
import 'my_rentals_page.dart'; // Import your new page
import 'update_user.dart';
import '../main.dart';
import '../api.dart';
import '../pages/rental_form_page.dart';

// side for udlejer til at poste lejligheder der kan lejes

class RentalHomepage extends StatelessWidget {
  final List<String> notifications = [
    'Besked 1',
    'Besked 2',
    'Besked 3',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hjem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RentalFormPage()
                      )
                    );
                  },
                  label: Text("Ny Lejlighed"),
                  icon: Icon(Icons.add),
                ),
              ),
              SizedBox(height: 20),
              notifications.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(notifications: notifications),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Du har ${notifications.length} beskeder',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () { 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyRentalsPage()),
                    );
                  },
                  label: Text("Mine Lejligheder"),
                  icon: Icon(Icons.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final List<String> notifications;

  NotificationScreen({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beskeder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Opening chat: ${notifications[index]}');
                },
                child: Text('Besked ${index + 1}: ${notifications[index]}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
