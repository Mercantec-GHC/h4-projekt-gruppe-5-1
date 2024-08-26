import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/rental_model.dart';

Future<List<RentalApartment>> fetchApartment(String id) async {
  if (id == "") {
    throw Exception("No ID");
  }

  final response = await http.get(Uri.parse('https://localhost:7014/api/Rentals/$id'));
  if (response.statusCode == 200) {
    final List<RentalApartment> apartment = <RentalApartment>[
      RentalApartment.fromJson(jsonDecode(response.body) as Map<String, dynamic>)
    ];

    return apartment;
  }
  else {
    throw Exception("Failed to fetch rental with id $id");
  }
}

Future<List<RentalApartmentThumb>> fetchApartments() async {
  final response = await http.get(Uri.parse('https://localhost:7014/api/Rentals'));
  if (response.statusCode == 200) {
    List<dynamic> jsonRentals = jsonDecode(response.body) as List<dynamic>;
    final List<RentalApartmentThumb> rentals = List.empty(growable: true);
    
    for (var i = 0; i < jsonRentals.length; i++) {
      rentals.add(RentalApartmentThumb.fromJson(jsonRentals[i]));
    }

    return rentals;
  }
  else {
    throw Exception("Failed to load rental.");
  }
}

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
                      onPressed: () => fetchApartment(_rentalIDController.text).then((result){
                        setState(() {
                          rentalList = result;
                        });
                      }),
                      child: const Text("Fetch apartment by ID")
                    )
                  )
                ],
              )
            ),
            const SizedBox(height: 15),
            */
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => fetchApartments().then((result){
                        setState(() {
                          rentalList = result;
                        });
                      }),
                      child: const Text("Fetch all apartments")
                    )
                  )
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
