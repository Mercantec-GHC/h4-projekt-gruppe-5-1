import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_input/image_input.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart' as main;

class UpdatePage extends StatefulWidget {
  final VoidCallback password;

  UpdatePage({required this.password});
  @override
  UpdatePageState createState() => UpdatePageState();
}

class UpdatePageState extends State<UpdatePage> {
  XFile? profileAvatarCurrentImage;
  bool allowEdit = true;
  final TextEditingController nameController = TextEditingController();

  var getImageSource = (BuildContext context) {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              child: const Text("Camera"),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            SimpleDialogOption(
                child: const Text("Gallery"),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                }),
          ],
        );
      },
    ).then((value) {
      return value ?? ImageSource.gallery;
    });
  };

  var getPrefferedCameraDevice = (BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Allow Camera Permission"),
        ),
      );
      return null;
    }
    return showDialog<CameraDevice>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              child: const Text("Rear"),
              onPressed: () {
                Navigator.of(context).pop(CameraDevice.rear);
              },
            ),
            SimpleDialogOption(
                child: const Text("Front"),
                onPressed: () {
                  Navigator.of(context).pop(CameraDevice.front);
                }),
          ],
        );
      },
    ).then(
      (value) {
        return value ?? CameraDevice.rear;
      },
    );
  };

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<main.MyAppState>();
    //var storage = main.storage;

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
          ),
          const Center(
            child: Text(
              "Profile Avatar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ProfileAvatar(
            image: profileAvatarCurrentImage,
            radius: 100,
            allowEdit: allowEdit,
            addImageIcon: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add_a_photo),
              ),
            ),
            removeImageIcon: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            ),
            onImageChanged: (XFile? image) {
              setState(() {
                profileAvatarCurrentImage = image;
              });
            },
            onImageRemoved: () {
              setState(() {
                profileAvatarCurrentImage = null;
              });
            },
            getImageSource: () async => await getImageSource(context),
            getPreferredCameraDevice: () async =>
                await getPrefferedCameraDevice(context),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              String name = nameController.text;

              await appState.updateUser(name);
            },
            icon: Icon(Icons.login),
            label: Text('Save changes'),
          ),
        ],
      ),
    ));
  }
}
