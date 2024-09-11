import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_input/image_input.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sks_booking/main.dart';

class RentalFormPage extends StatefulWidget {
  RentalFormPage({super.key});

  @override
  State<RentalFormPage> createState() => _RentalFormPageState();
}

class _RentalFormPageState extends State<RentalFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isVisibleToGuests = true;
  DateTime? bookingStartDate;
  DateTime? bookingEndDate;
  List<XFile> imagesToUpload = List.empty(growable: true);
  final dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  void updateGuestCheckboxValue(bool value) {
    setState(() {
      isVisibleToGuests = value;
    });
  }

  void updateImagesToUpload(List<XFile> files) {
    setState(() {
      imagesToUpload = files;
    });
  }

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

  void createSnackbarMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg))
    );
  }

  void prepareRental() {
    // Jeg gider virkelig ikke sætte Forms ordentligt op
    if (titleController.text.isEmpty || addressController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty) {
      createSnackbarMessage("Alle tekstfelter skal udfyldes");
      return;
    }

    if (int.tryParse(priceController.text) == null) {
      createSnackbarMessage("Prisfelt må kun indeholde tal");
      return;
    }

    if (bookingStartDate == null || bookingEndDate == null) {
      createSnackbarMessage("Begge datoer ikke valgt");
      return;
    }

    if (bookingEndDate!.isBefore(bookingStartDate!)) {
      createSnackbarMessage("Ugyldig periode");
      return;
    }

    String availableFrom = "${bookingStartDate!.toIso8601String()}Z";
    String availableUntil = "${bookingEndDate!.toIso8601String()}Z";

    createRental(availableFrom, availableUntil);
  }

  Future<void> createRental(String availableFrom, String availableUntil) async {
    String baseUrl = Provider.of<MyAppState>(context, listen: false).apiService.baseUrl;
    String? userID = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'id');
    String? userType = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'userType');
    var uri = '$baseUrl/Rentals';

    if (userID == null) {
      throw Exception('Failed to create booking: User ID is null');
    }

    if (userType == null || userType == "0") {
      throw Exception('Failed to create booking: Insufficient privileges');
    }

    var token = await Provider.of<MyAppState>(context, listen: false).apiService.secureStorage.read(key: 'token');

    List<MultipartFile> filesToUpload = List.empty(growable: true);
    for (var i = 0; i < imagesToUpload.length; i++) {
      filesToUpload.add(await MultipartFile.fromFile(imagesToUpload[i].path));
    }

    final formData = FormData.fromMap({
      'title': titleController.text,
      'address': addressController.text,
      'priceDaily': priceController.text,
      'description': descriptionController.text,
      'isVisibleToGuests': isVisibleToGuests,
      'availableFrom': availableFrom,
      'availableTo': availableUntil,
      'userID': userID,
      'galleryImages': filesToUpload
    });

    final response = await dio.post(
      uri,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 201) {
      createSnackbarMessage("Lejebolig oprettet!");
      Navigator.pop(context);
    }
    else {
      throw Exception('Failed to create rental: ${response.statusMessage} (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();

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
        title: Text("Ny lejebolig")
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
                  FormInputField(label: "Titel", textController: titleController, minSize: 1),
                  FormInputField(label: "Adresse", textController: addressController, minSize: 1),
                  FormInputField(label: "Pris per dag", textController: priceController, minSize: 1),
                  FormInputField(label: "Beskrivelse", textController: descriptionController, minSize: 4),
                  SizedBox(height: 8),
                  FormCheckbox(valueCallback: updateGuestCheckboxValue),
                  SizedBox(height: 16),
                  FormBookingRange(startCallback: datePickerStartCallback, endCallback: datePickerEndCallback),
                  SizedBox(height: 16),
                  Text("Billeder:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  FormLocalImages(filesCallback: updateImagesToUpload),
                  SizedBox(height: 16),
                  CreateRentalButton(function: () { prepareRental(); }),
                  SizedBox(height: 16),
                ],
              )
            )
          );
        }
      )
    );
  }
}

class FormInputField extends StatelessWidget {
  const FormInputField({
    super.key,
    required this.label,
    required this.textController,
    required this.minSize
  });

  final String label;
  final TextEditingController textController;
  final int minSize;

  void dispose() {
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        controller: textController,
        minLines: minSize,
        maxLines: 8,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}


class FormCheckbox extends StatefulWidget {
  const FormCheckbox({
    super.key,
    required this.valueCallback
  });

  final Function(bool) valueCallback;

  @override
  State<FormCheckbox> createState() => _FormCheckboxState();
}

class _FormCheckboxState extends State<FormCheckbox> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Lejebolig kan ses af gæster: ", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
            widget.valueCallback(value!); 
          },
        )
      ]
    );
  }
}


class FormBookingRange extends StatefulWidget {
  const FormBookingRange({
    required this.startCallback,
    required this.endCallback
  });

  final Function(DateTime) startCallback;
  final Function(DateTime) endCallback;

  @override
  State<FormBookingRange> createState() => _FormBookingRangeState();
}

class _FormBookingRangeState extends State<FormBookingRange> {
  final TextEditingController _startDateText = TextEditingController();
  final TextEditingController _endDateText = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool start) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      //initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730))
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _selectDate(context, true),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_month_outlined),
                  labelText: "Tilgængelig fra:",
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
                  labelText: "Tilgængelig til:",
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


class FormLocalImages extends StatefulWidget {
  const FormLocalImages({
    required this.filesCallback
  });

  final Function(List<XFile>) filesCallback;

  @override
  State<FormLocalImages> createState() => _FormLocalImagesState();
}

class _FormLocalImagesState extends State<FormLocalImages> {
  List<XFile> files = List.empty(growable: true);

  Future<void> selectPictures() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image ,allowMultiple: true);

    if (result != null) {
      files = result.paths.map((path) => XFile(path!)).toList();
      widget.filesCallback(files);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          files.isNotEmpty ? 
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(4)
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (XFile file in files) Flexible(child: FormImageThumb(file: file)),
                ],
              )
            ),
          )
          :
          Container(),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () { selectPictures(); },
            child: Text("Upload billeder")
          ),
        ]
      )
    );
  }
}

class FormImageThumb extends StatelessWidget {
  const FormImageThumb({
    required this.file
  });

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Image.file(File(file.path))
      )
    );
  }
}


class CreateRentalButton extends StatelessWidget {
  const CreateRentalButton({
    super.key,
    required this.function
  });

  final Function() function;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () { function(); },
      child: Text("Opret lejebolig")
    );
  }
}
