import 'package:flutter/material.dart';
import '../models/user_data_model.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.user});

  final UserData user;

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
                  SizedBox(height: 12),
                  UTop(name: user.name, pictureURL: user.profilePictureURL),
                  SizedBox(height: 12),
                  UBio(bio: user.bio!),
                  SizedBox(height: 12),
                  UContact(email: user.email, phone: user.phone)
                ],
              )
            )
          );
        }
      )
    );
  }
}

class UTop extends StatelessWidget {
  const UTop({
    super.key,
    required this.name,
    required this.pictureURL
  });

  final String name;
  final String? pictureURL;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        pictureURL != null ? 
        CircleAvatar(
          radius: 64,
          backgroundImage: NetworkImage(pictureURL!),
        )
        :
        Icon(
          Icons.circle,
          color: Colors.grey,
          size: 160
        ),
        SizedBox(height: 12),
        Text(name, style: TextStyle(fontSize: 22))
      ],
    );
  }
}

class UBio extends StatelessWidget {
  const UBio({
    super.key,
    required this.bio,
  });

  final String bio;

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
          Text(bio)
        ],
      )
    );
  }
}

class UContact extends StatelessWidget {
  const UContact({
    super.key,
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

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
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("E-mail:", style: TextStyle(fontSize: 15)),
              Text(email, style: TextStyle(fontSize: 15)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Telefon:", style: TextStyle(fontSize: 15)),
              Text(phone, style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      )
    );
  }
}
