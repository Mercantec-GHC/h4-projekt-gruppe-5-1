import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Fuld lejeboligmodel til lejeboligprofiler
class RentalApartment extends StatelessWidget {
  final String? title;
  final String address;
  final num priceDaily;
  final String description;
  final DateTime availableFrom;
  final DateTime availableTo;
  final bool isAvailable;
  final List<String> galleryURLs;
  final num renterID;
  final String renterName;
  final String renterEmail;
  final String? renterPictureURL;

  RentalApartment({
    required this.title,
    required this.address,
    required this.priceDaily,
    required this.description,
    required this.availableFrom,
    required this.availableTo,
    required this.isAvailable,
    required this.galleryURLs,
    required this.renterID,
    required this.renterName,
    required this.renterEmail,
    required this.renterPictureURL
  });

  RentalApartment.fromJson(Map<String, dynamic> json) :
    title = json['title'] as String?,
    address = json['address'] as String,
    priceDaily = json['priceDaily'] as num,
    description = json['description'] as String,
    availableFrom = DateTime.parse(json['availableFrom']),
    availableTo = DateTime.parse(json['availableTo']),
    isAvailable = DateTime.now().isBefore(DateTime.parse(json['availableTo'])),
    galleryURLs = json['galleryURLs']?.cast<String>() ?? List<String>.empty(),
    renterID = json['owner']['id'] as num,
    renterName = json['owner']['name'] as String,
    renterEmail = json['owner']['email'] as String,
    renterPictureURL = json['owner']['profilePictureURL'] as String?;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Afkortet lejeboligmodel. Brugt til lister
class RentalApartmentBrief extends StatelessWidget {
  final num id;
  final String address;
  final num priceDaily;
  final DateTime availableFrom;
  final DateTime availableTo;
  final String? imageURL;

  RentalApartmentBrief({
    required this.id,
    required this.address,
    required this.priceDaily,
    required this.availableFrom,
    required this.availableTo,
    required this.imageURL
  });

  RentalApartmentBrief.fromJson(Map<String, dynamic> json) :
    id = json['id'] as num,
    address = json['address'] as String,
    priceDaily = json['priceDaily'] as num,
    availableFrom = DateTime.parse(json['availableFrom']),
    availableTo = DateTime.parse(json['availableTo']),
    imageURL = json['imageURL'] as String?;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// ---------- THUMB ----------
// Afkortet lejeboligmodel med egen visning. Bliver brugt i get_rentals_page til listen
class RentalApartmentThumb extends StatelessWidget {
  final num id;
  final String address;
  final num priceDaily;
  final DateTime availableFrom;
  final DateTime availableTo;
  final bool isAvailable;
  final Function(num) callback;
  final String? imageURL;

  RentalApartmentThumb({
    required this.id,
    required this.address,
    required this.priceDaily,
    required this.availableFrom,
    required this.availableTo,
    required this.isAvailable,
    required this.callback,
    required this.imageURL
  });

  RentalApartmentThumb.fromJson(Map<String, dynamic> json, Function(num) cb) :
    id = json['id'] as num,
    address = json['address'] as String,
    priceDaily = json['priceDaily'] as num,
    availableFrom = DateTime.parse(json['availableFrom']),
    availableTo = DateTime.parse(json['availableTo']),
    isAvailable = DateTime.now().isBefore(DateTime.parse(json['availableTo'])),
    callback = cb,
    imageURL = json['imageURL'] as String?;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => {
          callback(id)
        }, 
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 1,
                child: 
                imageURL != null ? 
                SizedBox(
                  height: 56,
                  width: 72,
                  child: Image.network(imageURL!)
                )
                :
                Icon(
                  Icons.rectangle,
                  color: Colors.black,
                  size: 64,
                )
              ),
              SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(address, style: TextStyle(fontSize: 15))
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text("${priceDaily.toString()} kr./nat", style: TextStyle(fontSize: 14))
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text("${DateFormat("d/M/y").format(availableFrom)} - ${DateFormat("d/M/y").format(availableTo)}", style: TextStyle(fontSize: 12))
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Icon(
                  Icons.circle,
                  size: 24,
                  color: isAvailable ? Colors.green : Colors.red
                )
              )
            ],
          )
        ),
      )
    );
  }
}
