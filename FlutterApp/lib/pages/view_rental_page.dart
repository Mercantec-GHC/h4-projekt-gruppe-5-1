import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';
import 'package:provider/provider.dart';
import 'package:sks_booking/pages/rental_booking_page.dart';

import '../main.dart';
import '../models/rental_model.dart';
import '../models/user_data_model.dart';
import '../pages/user_profile_page.dart';

class ViewRentalPage extends StatefulWidget {
  const ViewRentalPage({super.key, required this.rental, required this.id});
  final RentalApartment rental;
  final num id;

  @override
  State<ViewRentalPage> createState() => _ViewRentalPageState();
}

class _ViewRentalPageState extends State<ViewRentalPage> {
  String bigImageSource = ""; // Placeholder værdi - tom string betyder intet billede

  @override
  void initState() {
    super.initState();

    // Hvis lejebolig har billeder, vis det første på den store plads
    if (widget.rental.galleryURLs.isNotEmpty) {
      bigImageSource = widget.rental.galleryURLs[0];
    }
  }

  // Henter relevant brugerdata på udlejer, hvis man trykker "Vis Profil"
  Future<UserData> fetchUser(num id) async {
    String baseUrl = Provider.of<MyAppState>(context, listen: false).apiService.baseUrl;
    final response = await http.get(Uri.parse('$baseUrl/Users/$id'));

    if (response.statusCode == 200) {
      final UserData user = UserData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      return user;
    }
    else {
      throw Exception("Failed to fetch user with id $id");
    }
  }

  void setBigImageSource(String url) {
    setState(() {
      bigImageSource = url;
    });
  }

  // Læser brugertype fra SecureStorage for at verificere brugerprivilegier
  Future<String?> getUserType() async {
    var value = await Provider.of<MyAppState>(context).apiService.secureStorage.read(key: 'userType');
    return value;
  }

  // Henter udlejer og viser ny side med deres brugerprofil
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

  // Viser ny side, hvor man kan booke
  void createBookingPage(RentalApartment rental) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentalBookingPage(rentalID: widget.id, from: widget.rental.availableFrom, to: widget.rental.availableTo)
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
                  RImageBig(url: bigImageSource),
                  SizedBox(height: 8),
                  RImagesSmall(urls: widget.rental.galleryURLs, imageCallback: setBigImageSource),
                  SizedBox(height: 12),
                  RDescription(text: widget.rental.description),
                  SizedBox(height: 8),
                  RAvailability(priceDaily: widget.rental.priceDaily, availableFrom: widget.rental.availableFrom, availableTo: widget.rental.availableTo, isAvailable: widget.rental.isAvailable),
                  SizedBox(height: 8),
                  RBooking(availableTo: widget.rental.availableTo, userType: getUserType, createBookingPage: () { createBookingPage(widget.rental); }),
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

class RImageBig extends StatefulWidget {
  const RImageBig({
    super.key,
    required this.url
  });

  final String url;

  @override
  State<RImageBig> createState() => _RImageBigState();
}

class _RImageBigState extends State<RImageBig> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350),
      child: AspectRatio(
        aspectRatio: 16/9,
        child: widget.url != "" ?
        Image.network(widget.url)
        :
        Container(
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
    required this.imageCallback
  });

  final List<String> urls;
  final Function(String) imageCallback;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (String url in urls) Flexible(child: RImageSmallInstance(url: url, imageCallback: imageCallback)),
        ],
      )
    );
  }
}

class RImageSmallInstance extends StatelessWidget {
  const RImageSmallInstance({
    super.key,
    required this.url,
    required this.imageCallback
  });

  final String url;
  final Function(String) imageCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { imageCallback(url); },
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Image.network(url)
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

class RBooking extends StatefulWidget {
  const RBooking({
    super.key,
    required this.availableTo,
    required this.userType,
    required this.createBookingPage
  });

  final DateTime availableTo;
  final Function() userType;
  final Function() createBookingPage;

  @override
  State<RBooking> createState() => _RBookingState();
}

class _RBookingState extends State<RBooking> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: widget.userType(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        return (snapshot.hasData && DateTime.now().isBefore(widget.availableTo)) ?
        Column(
          children: [ 
            ElevatedButton(
              onPressed: () { widget.createBookingPage(); },
              child: Text("Gå til booking")
            ),
            SizedBox(height: 8)
          ]
        )
        :
        Container();
      }
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
