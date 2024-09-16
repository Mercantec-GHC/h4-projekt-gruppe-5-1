import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_data_model.dart';
import '../models/rental_model.dart';
import '../pages/view_rental_page.dart';

// Side der viser alle lejligheder udlejer brugere har som en liste

class MyRentalsPage extends StatefulWidget {
  @override
  _MyRentalsPageState createState() => _MyRentalsPageState();
}

class _MyRentalsPageState extends State<MyRentalsPage> {
  late Future<List<RentalApartmentBrief>> _rentalsFuture;

  @override
  void initState() {
    super.initState();
    _rentalsFuture = _fetchRentals();
  }

  Future<RentalApartment> fetchApartment(num id) async {
    final response =
      await http.get(Uri.parse('https://localhost:7014/api/Rentals/$id'));
    if (response.statusCode == 200) {
      final RentalApartment apartment = RentalApartment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

      return apartment;
    } else {
      throw Exception("Failed to fetch rental with id $id");
    }
  }

  // Får fat i listen med lejligheder der tilhører den inloggede brugeren ved og finde ID i secure storage
  Future<List<RentalApartmentBrief>> _fetchRentals() async {
  try {
    String? userID = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'id');
    if (userID == null) {
      throw Exception("User ID not found in secure storage");
    }

    String? token = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'token');
    late final http.Response response;

    if (token != null) {
      response = await http.get(
        Uri.parse('https://localhost:7014/api/Users/$userID'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );
    } else {
      throw Exception("Invalid token");
    }

    //Decoder listen så at man kan se hver lejlighed separat i en liste
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> jsonRentals = data['rentals'] as List<dynamic>;
      final List<RentalApartmentBrief> rentals = [];

      for (var i = 0; i < jsonRentals.length; i++) {
        rentals.add(RentalApartmentBrief.fromJson(jsonRentals[i]));
      }

      return rentals;
    } else {
      throw Exception('Failed to load rentals: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Exception: $e');
    return [];
  }
}


  void prepareRentalPageByID(num id) {
      fetchApartment(id).then((result) {
        createRentalPage(result, id);
      });
    }

  void createRentalPage(RentalApartment rental, num id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRentalPage(rental: rental, id: id)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mine Rentals'),
      ),
      body: FutureBuilder<List<RentalApartmentBrief>>(
        future: _rentalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final rentals = snapshot.data!;
            return ListView.builder(
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return ListTile(
                  // title: Text(rental.title ?? 'No Title'),
                  subtitle: Text(rental.address),
                  onTap: () {
                    // Navigate to rental detail page
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No rentals found'));
          }
        },
      ),
    );
  }
}
