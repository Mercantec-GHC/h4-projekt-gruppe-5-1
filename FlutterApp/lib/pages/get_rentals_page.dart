import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sks_booking/main.dart';

import '../models/rental_model.dart';
import '../pages/view_rental_page.dart';

class GetRentalsPage extends StatefulWidget {
  const GetRentalsPage({super.key});

  @override
  State<GetRentalsPage> createState() => _GetRentalsPageState();
}

class _GetRentalsPageState extends State<GetRentalsPage> {
  List<RentalApartmentThumb> rentalList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  Future<String?> getUserType() async {
    var value = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'userType');
    return value;
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

  Future<List<RentalApartmentThumb>> fetchApartments() async {
    String? userType = await getUserType();
    late final dynamic response;

    if (userType == null) {
      response = await http.get(Uri.parse('https://localhost:7014/api/Rentals/Guest'));
    }
    else {
      String? token = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'token');
      
      if (token != null) {
        response = await http.get(Uri.parse('https://localhost:7014/api/Rentals'), headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
        });
      }
      else {
        throw Exception("Invalid token");
      }
    }
    
    if (response.statusCode == 200) {
      List<dynamic> jsonRentals = jsonDecode(response.body) as List<dynamic>;
      final List<RentalApartmentThumb> rentals = List.empty(growable: true);

      for (var i = 0; i < jsonRentals.length; i++) {
        rentals.add(RentalApartmentThumb.fromJson(
          jsonRentals[i], prepareRentalPageByID));
      }

      return rentals;
    } 
    else {
      throw Exception("Failed to load rental.");
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
      appBar: AppBar(title: const Text('Fetch Data')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => fetchApartments().then((result) {
                        setState(() {
                          rentalList = result;
                        });
                      }),
                  child: const Text("Fetch all apartments")))
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              flex: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView.builder(
                      itemCount: rentalList.length,
                      itemBuilder: (context, index) {
                        return rentalList[index];
                      },
                    )
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }
}
