import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' as main;

class BiographyUpdater extends StatefulWidget {
  final VoidCallback onUser;
  final Future<Map<String, dynamic>> userData;
  BiographyUpdater({required this.onUser, required this.userData});
  @override
  BiographyUpdaterState createState() => BiographyUpdaterState();
}

class BiographyUpdaterState extends State<BiographyUpdater> {
  late TextEditingController _biographyController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with empty text initially
    _biographyController = TextEditingController();

    // Fetch user data and set name
    widget.userData.then((user) {
      setState(() {
        _biographyController.text = user['biography'] ?? '';
      });
    }).catchError((error) {
      print("Fejl ved hentning af brugerdata: $error");
    });
  }

  @override
  void dispose() {
    _biographyController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    final myAppState = Provider.of<main.MyAppState>(context, listen: false);

    try {
      // Send det indtastede navn videre til opdateringsmetoden
      var response = myAppState.updateUserBio(_biographyController.text);
      print(response);
      // Hvis opdateringen lykkes, vis en SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biografi opdateret')),
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
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _biographyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Skriv lidt om dig selv her',
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _updateUser,
            icon: Icon(Icons.update),
            label: Text('Gem biografi'),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onUser,
              icon: Icon(Icons.person),
              label: Text('Opdater bruger'),
            ),
          )
        ],
      ),
    ));
  }
}
