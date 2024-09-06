import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';

import '../models/rental_model.dart';
import '../models/user_data_model.dart';
import '../pages/user_profile_page.dart';

class ViewRentalPage extends StatefulWidget {
  const ViewRentalPage({super.key, required this.rental});
  final RentalApartment rental;

  @override
  State<ViewRentalPage> createState() => _ViewRentalPageState();
}

class _ViewRentalPageState extends State<ViewRentalPage> {
  late num noOfImages;

  @override
  void initState() {
    super.initState();
    noOfImages = widget.rental.galleryURLs.length;
  }

  Future<UserData> fetchUser(num id) async {
    final response = await http.get(Uri.parse('https://localhost:7014/api/Users/$id'));
    if (response.statusCode == 200) {
      final UserData user = UserData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

      return user;
    }
    else {
      throw Exception("Failed to fetch user with id $id");
    }
  }

  void prepareUserPageByID(num id) {
    fetchUser(id).then((result) {
      createUserPage(result);
    });
  }

  void createUserPage(UserData user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(user: user)
      )
    );
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
                  Flexible(
                    child: RTop(title: widget.rental.title, address: widget.rental.address),
                  ),
                  SizedBox(height: 8),
                  RImageBig(),
                  SizedBox(height: 8),
                  RImagesSmall(urls: widget.rental.galleryURLs, count: noOfImages), // Hvis billedet bliver lavet til en "carousel", fjern dette
                  SizedBox(height: 12),
                  RDescription(text: widget.rental.description),
                  //RDescription(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
                  SizedBox(height: 8),
                  RAvailability(priceDaily: widget.rental.priceDaily, availableFrom: widget.rental.availableFrom, availableTo: widget.rental.availableTo, isAvailable: widget.rental.isAvailable),
                  SizedBox(height: 8),
                  ROwner(name: widget.rental.renterName, email: widget.rental.renterEmail, pictureURL: widget.rental.renterPictureURL, getUser: () { prepareUserPageByID(widget.rental.renterID); })
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
    required this.title,
    required this.address,
  });

  final String? title;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title ?? "", style: TextStyle(fontSize: 18)), 
            Text(address, style: TextStyle(fontSize: 15))
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350),
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Container(
          color: Colors.grey[800]
        )
      )
    );
  }
}

class RImagesSmall extends StatelessWidget {
  const RImagesSmall({
    super.key,
    required this.urls,
    required this.count
  });

  final List<String> urls;
  final num count;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350),
      child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (String url in urls) Flexible(child: RImageSmallInstance(url: url)),
        //SizedBox(width: 8),
        //Flexible(child: RImageSmallInstance()),
        //SizedBox(width: 8),
        //Flexible(child: RImageSmallInstance()),
      ],
      )
    );
  }
}

class RImageSmallInstance extends StatelessWidget {
  const RImageSmallInstance({
    super.key,
    required this.url
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: Image.network(url)
      //child: Container(
      //  color: Colors.grey[800],
      //)
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
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12)
      ),
      child: ExpandableText(
        text,
        expandText: "vis mere",
        collapseText: "vis mindre",
        maxLines: 4,
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
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
        DateTime.now().isBefore(from) ? Text("Kan lejes fra ${DateFormat("d/M").format(from)}") : Container()
      ]
    );
  }
}

class ROwner extends StatelessWidget {
  const ROwner({
    super.key,
    required this.name,
    required this.email,
    required this.pictureURL,
    required this.getUser
  });

  final String name;
  final String email;
  final String? pictureURL;
  final Function() getUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      color: Color(0xFFCAC3A5),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: null,
        collapsedBackgroundColor: null,
        iconColor: Colors.grey[800],
        collapsedIconColor: Colors.grey[800],
        
        leading: pictureURL != null ? 
        CircleAvatar(
          backgroundImage: NetworkImage(pictureURL!),
        )
        :
        Icon(
          Icons.circle,
          color: Colors.grey,
          size: 48
        ),

        title: Text(name),
        subtitle: Text(email),
        children: [
          Material(
            child: ListTile(
              minTileHeight: 12,
              title: Text('Vis profil', textAlign: TextAlign.center),
              tileColor: Color(0xFFFFFFFF),
              onTap: () { getUser(); },
            ),
          ),
        ],
      ),
    );
  }
}
