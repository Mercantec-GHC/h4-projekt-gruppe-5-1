import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_input/image_input.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart' as main;

class UpdatePage extends StatefulWidget {
  final VoidCallback onBio;
  final Future<Map<String, dynamic>> userData;

  const UpdatePage({required this.userData, required this.onBio});
  @override
  UpdatePageState createState() => UpdatePageState();
}

class UpdatePageState extends State<UpdatePage> {
  XFile? profileAvatarCurrentImage;
  bool allowEdit = true;
  String? imageUrl;
  late TextEditingController _nameController;

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
  void initState() {
    super.initState();
    // Initialize controller with empty text initially
    _nameController = TextEditingController();

    // Fetch user data and set name
    widget.userData.then((user) {
      setState(() {
        imageUrl = user['profilePictureURL'];
        // Hent 'name' fra mappen og opdater feltet
        _nameController.text = user['name'] ?? '';
      });
    }).catchError((error) {
      print("Fejl ved hentning af brugerdata: $error");
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    final myAppState = Provider.of<main.MyAppState>(context, listen: false);
    
    try {
      // Send det indtastede navn videre til opdateringsmetoden
      await myAppState.updateUser(_nameController.text, profileAvatarCurrentImage, imageUrl );
      // Hvis opdateringen lykkes, vis en SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil oplysninger opdateret')),
      );
    } catch (e) {
      print('Fejl ved opdatering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved opdatering')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //var storage = main.storage;

    return Scaffold(
        appBar: AppBar(
          title: Text('Opdater bruger'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: _nameController,
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
                imageUrl: imageUrl,
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
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                ),
                onImageChanged: (XFile? image) {
                  setState(() {
                    profileAvatarCurrentImage = image;
                  });
                },
                getImageSource: () async => await getImageSource(context),
                getPreferredCameraDevice: () async =>
                    await getPrefferedCameraDevice(context),
              ),
              ElevatedButton.icon(
                onPressed: _updateUser,
                icon: Icon(Icons.update),
                label: Text('Gem bruger oplysninger'),
              ),
              Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: widget.onBio,
              icon: Icon(Icons.switch_account),
              label: Text('bruger'),
            ),
            )
            ],
          ),
        ));
  }
}
