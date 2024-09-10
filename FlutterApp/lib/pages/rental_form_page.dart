import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

  bool isVisibleToGuests = true;

  void updateGuestCheckboxValue(bool value) {
    setState(() {
      isVisibleToGuests = value;
    });
  }

  void debugPrint() {
    print("Title: ${titleController.text}, Address: ${addressController.text}, Price: ${priceController.text}, Description: ${descriptionController.text}, Guests: ${isVisibleToGuests}");
  }

  bool passwordMatch = true;

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
                  FormCheckbox(valueCallback: updateGuestCheckboxValue),
                  CreateRentalButton(function: () { debugPrint(); })
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Lejebolig kan ses af gæster: "),
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
      child: Text("Test")
    );
  }
}
