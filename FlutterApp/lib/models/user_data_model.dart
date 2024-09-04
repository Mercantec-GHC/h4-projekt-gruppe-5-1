import 'package:flutter/material.dart';
import 'package:sks_booking/models/rental_model.dart';

class UserData extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final List<RentalApartment>? rentals;

  UserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.rentals
  });

  UserData.fromJson(Map<String, dynamic> json) :
    name = json['name'] as String,
    email = json['email'] as String,
    phone = json['phoneNumber'] as String,
    rentals = json['rentals'] as List<RentalApartment>?;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
