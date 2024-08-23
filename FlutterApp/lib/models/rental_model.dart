import 'package:flutter/material.dart';

class RentalApartmentThumb extends StatelessWidget {
  final String address;
  final num priceDaily;
  final String description;
  final DateTime availableFrom;
  final DateTime availableTo;

  RentalApartmentThumb({
    required this.address,
    required this.priceDaily,
    required this.description,
    required this.availableFrom,
    required this.availableTo
  });

  RentalApartmentThumb.fromJson(Map<String, dynamic> json) :
    address = json['address'] as String,
    priceDaily = json['priceDaily'] as num,
    description = json['description'] as String,
    availableFrom = DateTime.parse(json['availableFrom']),
    availableTo = DateTime.parse(json['availableTo']);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(address),
        Text(priceDaily.toString()),
        Text(description),
        Text(availableFrom.toString()),
        Text(availableTo.toString())
      ],
    );
  }
}
