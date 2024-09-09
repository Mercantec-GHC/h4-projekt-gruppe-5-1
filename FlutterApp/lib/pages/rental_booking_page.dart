import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';

import '../models/rental_model.dart';

class RentalBookingPage extends StatefulWidget {
  const RentalBookingPage({super.key, required this.rental});
  final RentalApartment rental;

  @override
  State<RentalBookingPage> createState() => _RentalBookingPageState();
}

class _RentalBookingPageState extends State<RentalBookingPage> {
  late num noOfImages;

  @override
  void initState() {
    super.initState();
    noOfImages = widget.rental.galleryURLs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1EFE7),
      appBar: AppBar(
        backgroundColor: Color(0xFFCAC3A5),
        leading: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(0)
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
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RBooking(availableFrom: widget.rental.availableFrom, availableTo: widget.rental.availableTo)
                ],
              )
            )
          );
        }
      )
    );
  }
}

class RBooking extends StatefulWidget {
  const RBooking({
    super.key,
    required this.availableFrom,
    required this.availableTo,
  });

  final DateTime availableFrom;
  final DateTime availableTo;

  @override
  State<RBooking> createState() => _RBookingState();
}

class _RBookingState extends State<RBooking> {
  late DateTime bookingStartDate;
  late DateTime bookingEndDate;

  final TextEditingController _startDateText = TextEditingController();
  final TextEditingController _endDateText = TextEditingController();

  void _generateCalendarCatalog() {

  }

  Future<void> _selectDate(BuildContext context, bool start) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        //initialDate: selectedDate,
        firstDate: widget.availableFrom,
        lastDate: widget.availableTo
      );

      if (picked != null) {
        setState(() {
          start ? bookingStartDate = picked : bookingEndDate = picked;
          start ? _startDateText.text = "${DateFormat("d/M/y").format(bookingStartDate)}" : _endDateText.text = "${DateFormat("d/M/y").format(bookingEndDate)}";
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _selectDate(context, true),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_month_outlined),
                  labelText: "Startdato:",
                ),
                controller: _startDateText,
              )
            )
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context, false),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_month_outlined),
                  labelText: "Slutdato:",
                ),
                controller: _endDateText,
              )
            )
          )
        ],
      )
    );
  }
}