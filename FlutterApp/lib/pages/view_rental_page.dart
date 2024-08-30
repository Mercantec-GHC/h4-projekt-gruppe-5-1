import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expandable_text/expandable_text.dart';

import '../models/rental_model.dart';

class ViewRentalPage extends StatelessWidget {
  const ViewRentalPage({super.key, required this.rental});

  final RentalApartment rental;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1EFE7),
      appBar: AppBar(
        backgroundColor: Color(0xFFCAC3A5),
        leading: TextButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(0))
          ),
          onPressed: () { Navigator.pop(context); }, 
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 32
          )
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: RTop(address: rental.address),
                    ),
                    SizedBox(height: 8),
                    Flexible(child: RImageBig()),
                    SizedBox(height: 8),
                    RImagesSmall(), // Hvis billedet bliver lavet til en "carousel", fjern dette
                    SizedBox(height: 12),
                    //RDescription(text: rental.description),
                    RDescription(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
                    SizedBox(height: 8),
                    RAvailability(priceDaily: rental.priceDaily, availableFrom: rental.availableFrom, availableTo: rental.availableTo, isAvailable: rental.isAvailable),
                  ],
                )
              )
          );
        }
      )
    );
  }
}

class RTop extends StatelessWidget {
  const RTop({
    super.key,
    required this.address,
  });

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Title!", style: TextStyle(fontSize: 18)), 
            Text(address, style: TextStyle(fontSize: 15))
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Icon(
            Icons.map,
            size: 48
          )],
        )
      ],
    );
  }
}

class RImageBig extends StatelessWidget {
  const RImageBig({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: Container(
        color: Colors.grey[800]
      )
    );
  }
}

class RImagesSmall extends StatelessWidget {
  const RImagesSmall({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: RImageSmallInstance()),
        SizedBox(width: 8),
        Flexible(child: RImageSmallInstance()),
        SizedBox(width: 8),
        Flexible(child: RImageSmallInstance()),
      ],
    );
  }
}

class RImageSmallInstance extends StatelessWidget {
  const RImageSmallInstance({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: Container(
        color: Colors.grey[800],
      )
    );
  }
}

class RDescription extends StatelessWidget {
  const RDescription({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, 0),
      padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12)
      ),
      child: ExpandableText(
        text,
        expandText: "show more",
        collapseText: "show less",
        maxLines: 3,
        linkColor: Colors.blue,
        animation: true,
        animationDuration: Duration(milliseconds: 500),
        expandOnTextTap: true,
        collapseOnTextTap: true,
      )
    );
  }
}

class RAvailability extends StatelessWidget {
  const RAvailability({
    super.key,
    required this.priceDaily,
    required this.availableFrom,
    required this.availableTo,
    required this.isAvailable,
  });

  final num priceDaily;
  final DateTime availableFrom;
  final DateTime availableTo;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("${priceDaily.toString()} kr./nat", style: TextStyle(fontSize: 18)),
          isAvailable ? RAvailableTrue(from: availableFrom, to: availableTo) : RAvailableFalse(from: availableFrom, to: availableTo)
        ],
      )
    );
  }
}

class RAvailableTrue extends StatelessWidget {
  const RAvailableTrue({
    super.key,
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) {
    return Text("${DateFormat("d/M/y").format(from)} - ${DateFormat("d/M/y").format(to)}", style: TextStyle(fontSize: 14));
  }
}

class RAvailableFalse extends StatelessWidget {
  const RAvailableFalse({
    super.key,
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ikke tilgængelig", style: TextStyle(fontSize: 16, color: Colors.red[800])),
        DateTime.now().isAfter(from) ? Text("Kan lejes fra ${DateFormat("d/M").format(from)}") : Container()
      ]
    );
  }
}
