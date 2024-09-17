import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sks_booking/api.dart';

class AccountUpdater extends StatefulWidget {
  final VoidCallback onPassword;
  final Future<Map<String, dynamic>> userData;
  AccountUpdater({required this.onPassword, required this.userData});
  @override
  AccountUpdaterState createState() => AccountUpdaterState();
}

class AccountUpdaterState extends State<AccountUpdater> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with empty text initially
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();

    // Fetch user data and set name
    widget.userData.then((user) {
      setState(() {
        // Hent 'name' fra mappen og opdater feltet
        _usernameController.text = user['username'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneNumberController.text = user['phoneNumber'] ?? '';
      });
    }).catchError((error) {
      print("Fejl ved hentning af brugerdata: $error");
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    final myAppState = Provider.of<ApiService>(context, listen: false);

    try {
      // Send det indtastede navn videre til opdateringsmetoden
      myAppState.updateAccount(_usernameController.text,
          _emailController.text, _phoneNumberController.text);

      // Hvis opdateringen lykkes, vis en SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kontooplysninger opdateret')),
      );
    } catch (e) {
      print('Fejl ved opdatering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved opdatering')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Telefonnummer',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Brugernavn',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _updateUser,
            icon: Icon(Icons.update),
            label: Text('Gem kontooplysninger'),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onPassword,
              icon: Icon(Icons.person),
              label: Text('Skift password'),
            ),
          )
        ],
      ),
    ));
  }
}
