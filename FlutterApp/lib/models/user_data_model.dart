import 'package:flutter/material.dart';
import 'package:sks_booking/models/rental_model.dart';

class UserData extends StatelessWidget {
  final String id;
  final String name;
  final String? bio;
  final String email;
  final String phone;
  final String? profilePictureURL;
  final List<RentalApartment>? rentals;

  UserData({
    required this.id,
    required this.name,
    this.bio,
    required this.email,
    required this.phone,
    this.profilePictureURL,
    this.rentals
  });

  UserData.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'] as String,
        bio = json['biography'] as String?,
        email = json['email'] as String,
        phone = json['phoneNumber'] as String,
        profilePictureURL = json['profilePictureURL'] as String?,
        rentals = json['rentals'] as List<RentalApartment>?;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
