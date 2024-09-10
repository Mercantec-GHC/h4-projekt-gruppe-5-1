import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/rental_model.dart';

class MyRentalsPage extends StatefulWidget {
  @override
  _MyRentalsPageState createState() => _MyRentalsPageState();
}

class _MyRentalsPageState extends State<MyRentalsPage> {
  late Future<List<RentalApartment>> _rentalsFuture;

  @override
  void initState() {
    super.initState();
    _rentalsFuture = _fetchRentals();
  }

  Future<List<RentalApartment>> _fetchRentals() async {
  try {
    String? userID = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'id');
    if (userID == null) {
      throw Exception("User ID not found in secure storage");
    }
    final response = await http.get(Uri.parse('https://localhost:7014/api/Rentals/$userID'));

    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((item) => RentalApartment.fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final rental = RentalApartment.fromJson(data as Map<String, dynamic>);
        return [rental];
      } else {
        throw Exception('Unexpected JSON format');
      }
    } else {
      throw Exception('Failed to load rentals: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Exception: $e');
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mine Rentals'),
      ),
      body: FutureBuilder<List<RentalApartment>>(
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
                  title: Text(rental.title ?? 'No Title'),
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
