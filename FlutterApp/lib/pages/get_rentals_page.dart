import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/rental_model.dart';
import '../pages/view_rental_page.dart';

class GetRentalsPage extends StatefulWidget {
  const GetRentalsPage({super.key});

  @override
  State<GetRentalsPage> createState() => _GetRentalsPageState();
}

class _GetRentalsPageState extends State<GetRentalsPage> {
  List<RentalApartmentThumb> rentalList = List.empty(growable: true);
  //final TextEditingController _rentalIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    final response =
        await http.get(Uri.parse('https://localhost:7014/api/Rentals'));
    if (response.statusCode == 200) {
      List<dynamic> jsonRentals = jsonDecode(response.body) as List<dynamic>;
      final List<RentalApartmentThumb> rentals = List.empty(growable: true);

      for (var i = 0; i < jsonRentals.length; i++) {
        rentals.add(RentalApartmentThumb.fromJson(
            jsonRentals[i], prepareRentalPageByID));
      }

      return rentals;
    } else {
      throw Exception("Failed to load rental.");
    }
  }

  void prepareRentalPageByID(num id) {
    fetchApartment(id).then((result) {
      createRentalPage(result);
    });
  }

  void createRentalPage(RentalApartment rental) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRentalPage(rental: rental)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fetch Data')),
      body: Center(
        child: Column(
          children: [
            /*
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 80,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _rentalIDController
                      ),
                    )
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => prepareRentalPageByID(num.parse(_rentalIDController.text)),
                      /*
                      onPressed: () => fetchApartment(num.parse(_rentalIDController.text)).then((result){
                        setState(() {
                          
                        });
                      }),
                      */
                      child: const Text("Fetch apartment by ID")
                    )
                  )
                ],
              )
            ),
            */
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
