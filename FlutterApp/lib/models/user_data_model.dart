import 'package:flutter/material.dart';
import 'package:sks_booking/models/rental_model.dart';

// Brugerdatamodel uden tilhørende lejeboliger
class UserData extends StatelessWidget {
  final String name;
  final String bio;
  final String email;
  final String phone;
  final String? profilePictureURL;

  UserData({
    required this.name,
    required this.bio,
    required this.email,
    required this.phone,
    required this.profilePictureURL,
  });

  UserData.fromJson(Map<String, dynamic> json) :
    name = json['name'] as String,
    bio = json['biography'] as String,
    email = json['email'] as String,
    phone = json['phoneNumber'] as String,
    profilePictureURL = json['profilePictureURL'] as String?;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Brugerdatamodel med tilhørende lejeboliger
class ExtendedUserData extends StatelessWidget {
  final String name;
  final String bio;
  final String email;
  final String phone;
  final String? profilePictureURL;
  final List<RentalApartmentBrief> rentals;

  ExtendedUserData({
    required this.name,
    required this.bio,
    required this.email,
    required this.phone,
    required this.profilePictureURL,
    required this.rentals
  });

  ExtendedUserData.fromJson(Map<String, dynamic> json) :
    name = json['name'] as String,
    bio = json['biography'] as String,
    email = json['email'] as String,
    phone = json['phoneNumber'] as String,
    profilePictureURL = json['profilePictureURL'] as String?,
    rentals = json['rentals']?.cast<RentalApartmentBrief>() ?? List<RentalApartmentBrief>.empty();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
