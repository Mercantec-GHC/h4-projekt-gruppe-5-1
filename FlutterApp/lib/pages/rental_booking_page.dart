import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../main.dart';

class RentalBookingPage extends StatefulWidget {
  const RentalBookingPage({
    super.key, 
    required this.rentalID,
    required this.from,
    required this.to
  });

  final num rentalID;
  final DateTime from;
  final DateTime to;

  @override
  State<RentalBookingPage> createState() => _RentalBookingPageState();
}

class _RentalBookingPageState extends State<RentalBookingPage> {
  DateTime? bookingStartDate;
  DateTime? bookingEndDate;

  void datePickerStartCallback(DateTime startDate) {
    setState(() {
      bookingStartDate = startDate;
    });
  }

  void datePickerEndCallback(DateTime endDate) {
    setState(() {
      bookingEndDate = endDate;
    });
  }

  // Tom metode der ellers ville være brugt til at udregne og filtrere allerede bookede tider for en lejlighed
  // Da DatePicker kan modtage en delegate med tilgængelige datoer, ville en måde at gøre det på være,
  // at der blev lavet et Set med alle gyldige datoer, og derefter ville alle date ranges fra bookingtabellen
  // blive trukket fra, hvilket efterlader kun åbne datoer til sidst.
  // Dette nåede jeg ikke
  void _generateCalendarCatalog() {

  }

  // Forbereder og validerer brugerinput inden POST request
  void prepareBooking() {
    if (bookingStartDate == null || bookingEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Begge datoer ikke valgt"))
      );
      return;
    }

    if (bookingEndDate!.isBefore(bookingStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ugyldig bookingperiode"))
      );
      return;
    }

    // Se kommentar i rental_form_page.dart
    String bookFrom = "${bookingStartDate!.toIso8601String()}Z";
    String bookUntil = "${bookingEndDate!.toIso8601String()}Z";

    String rentalID = widget.rentalID.toString();
    createBooking(rentalID, bookFrom, bookUntil);
  }

  // POST request til backend, som tilføjer booking til databasen
  Future<void> createBooking(String rentalID, String bookFrom, String bookUntil) async {
    String baseUrl = Provider.of<MyAppState>(context, listen: false).apiService.baseUrl;
    String? userID = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'id');

    if (userID == null) {
      throw Exception('Failed to create booking: User ID is null');
    }

    var token = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'token');
    
    var uri = Uri.parse('$baseUrl/Bookings');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userID': userID,
        'rentalID': rentalID,
        'bookedFrom': bookFrom,
        'bookedUntil': bookUntil
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking oprettet!"))
      );
      Navigator.pop(context);
    }
    else {
      throw Exception('Failed to create booking: ${response.reasonPhrase} (${response.statusCode})');
    }
  }

  @override
  void initState() {
    super.initState();
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
                  RBooking(availableFrom: widget.from, availableTo: widget.to, startCallback: datePickerStartCallback, endCallback: datePickerEndCallback),
                  SizedBox(height: 16),
                  CreateBookingButton(function: () { prepareBooking(); })
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
    required this.startCallback,
    required this.endCallback
  });

  final DateTime availableFrom;
  final DateTime availableTo;
  final Function(DateTime) startCallback;
  final Function(DateTime) endCallback;

  @override
  State<RBooking> createState() => _RBookingState();
}

class _RBookingState extends State<RBooking> {
  final TextEditingController _startDateText = TextEditingController();
  final TextEditingController _endDateText = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool start) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: widget.availableFrom,
      lastDate: widget.availableTo
    );

    if (picked != null) {
      setState(() {
        start ? widget.startCallback(picked) : widget.endCallback(picked);
        start ? _startDateText.text = DateFormat("d/M/y").format(picked) : _endDateText.text = DateFormat("d/M/y").format(picked);
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
          ),
        ],
      )
    );
  }
}

class CreateBookingButton extends StatelessWidget {
  const CreateBookingButton({
    super.key,
    required this.function
  });

  final Function() function;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () { function(); },
      child: Text("Book")
    );
  }
}
