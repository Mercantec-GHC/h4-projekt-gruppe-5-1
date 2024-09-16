import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';

// side for almindelige brugere der skal leje en lejlighed

class RenterHomepage extends StatefulWidget {
  @override
  _RenterHomePageState createState() => _RenterHomePageState();
}

class _RenterHomePageState extends State<RenterHomepage> {
  LatLng? _currentLocation;
  LatLng? _searchLocation;
  List<PointOfInterest> _pointsOfInterest = [];
  late MapController _mapController;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (kIsWeb) { // Midlertidig løsning, fordi jeg hader virkelig at alting låser, når jeg tester ting - Freja
      _getCurrentLocation();
    }
    else if (!Platform.isWindows) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationData? locationData;

    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    setState(() {
      if (locationData != null) {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _getPointsOfInterest();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentLocation != null) {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=10');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse.isNotEmpty) {
          final lat = double.parse(jsonResponse[0]['lat']);
          final lon = double.parse(jsonResponse[0]['lon']);

          setState(() {
            _searchLocation = LatLng(lat, lon);
            _moveToLocation(_searchLocation!);
          });
        }
      } else {
        throw Exception('Fandt ikke lokationen');
      }
    }
  }

  // Finder "interesser" indenfor en radius af kordinaterne til brugere. Radius et rektangel og ikke en sirkel.
  Future<void> _getPointsOfInterest() async {
  if (_currentLocation != null) {
    final query = """
    [out:json];
    (
      node["amenity"="restaurant"](${_currentLocation!.latitude - _searchRadius},${_currentLocation!.longitude - _searchRadius},${_currentLocation!.latitude + _searchRadius},${_currentLocation!.longitude + _searchRadius});
      node["tourism"="museum"](${_currentLocation!.latitude - _searchRadius},${_currentLocation!.longitude - _searchRadius},${_currentLocation!.latitude + _searchRadius},${_currentLocation!.longitude + _searchRadius});
      node["amenity"="cafe"](${_currentLocation!.latitude - _searchRadius},${_currentLocation!.longitude - _searchRadius},${_currentLocation!.latitude + _searchRadius},${_currentLocation!.longitude + _searchRadius});
    );
    out body;
    """;

    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final elements = jsonResponse['elements'] as List;

      List<PointOfInterest> pointsOfInterest = elements.map((e) {
        return PointOfInterest(
          name: e['tags']['name'] ?? 'Unnamed',
          latLng: LatLng(e['lat'], e['lon']),
          type: e['tags']['amenity'] ?? e['tags']['tourism'] ?? 'Unknown',
        );
      }).toList();

      setState(() {
        _pointsOfInterest = pointsOfInterest;
      });
    } else {
      throw Exception('Fejlet at finde interessepunkter');
    }
  }
}

  void _moveToLocation(LatLng latLng) {
    setState(() {
      _mapController.move(latLng, 15.0);
    });
  }

  void _onPointOfInterestTapped(PointOfInterest poi) {
    setState(() {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: poi.latLng,
          child: Icon(Icons.location_on, color: const Color.fromARGB(255, 27, 136, 183), size: 40),
        ),
      );

      _moveToLocation(poi.latLng);
    });
  }

  double _searchRadius = 0.01;

  // justerer radiuset for openstreetmaps til at finde de specifike tyber "interesser" der er definert tidligere i koden.
  Widget _buildRadiusSlider() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Søge Radius: ${(_searchRadius * 111).toStringAsFixed(2)} km'),
      Slider(
        value: _searchRadius,
        min: 0.005,  // Minimum radius (e.g., 0.5 km)
        max: 0.20,   // Maximum radius (e.g., 20 km)
        divisions: 10,
        label: '${(_searchRadius * 111).toStringAsFixed(2)} km',
        onChanged: (value) {
          setState(() {
            _searchRadius = value;
            _getPointsOfInterest();
          });
        },
      ),
    ],
  );
}

  final List<Apartment> apartments = [
    Apartment(
      name: "Apartment 1",
      description: "Description for Apartment 1",
      imageUrl: "https://christian.hammervig.dk/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fwelcome.3009bb93.jpg&w=256&q=75",
    ),
    Apartment(
      name: "Apartment 2",
      description: "Description for Apartment 2",
      imageUrl: "https://christian.hammervig.dk/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ffaerdigkarrosse.cfd8624a.jpg&w=256&q=75",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hjem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: apartments.map((apartment) {
                  return ApartmentWidget(
                    apartment: apartment,
                    onTap: () {
                      // Navigate to the ApartmentDetailScreen when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApartmentDetailScreen(apartment: apartment),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // _buildLejlighederSection(),
              // SizedBox(height: 20),
              Column(
                children: [
                  _buildRadiusSlider(),
                  _buildMapSection(),
                  _buildSearchBar(),
                  SizedBox(height: 10),
                  _buildPointsOfInterestSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsOfInterestSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interessepunkter',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 15),
          _buildPointsOfInterestList(),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterestList() {
    if (_pointsOfInterest.isEmpty) {
      return Text('Fandt ikke nogle interessepunkter.');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _pointsOfInterest.length,
      itemBuilder: (context, index) {
        final poi = _pointsOfInterest[index];
        return ListTile(
          leading: Icon(Icons.place),
          title: Text(poi.name),
          subtitle: Text(poi.type),
          onTap: () {
            _onPointOfInterestTapped(poi);
          },
        );
      },
    );
  }

  Widget _buildMapSection() {
    final List<Marker> markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(47.497913, 19.040236),
        child: Icon(Icons.location_on, color: Colors.blue, size: 40),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(47.5086157102635, 19.048331574749856),
        child: Icon(Icons.location_on, color: Colors.green, size: 40),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(47.50220329515141, 19.053128886277953),
        child: Icon(Icons.location_on, color: Colors.orange, size: 40),
      ),
    ];

    // ville være en videre udviddelse med kordinater til lejlighederne men gik tom for tid
    // final List<Marker> lejlighedskordinater = [
    //   Marker(
    //     width: 80.0,
    //     height: 80.0,
    //     point: kordinatene fra leilighetene skal inn som en variabel her, 
    //     child: Icon(Icons.location_on, color: Colors.amber, size: 40),
    //   ),
    // ];

    if (_currentLocation != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentLocation!,
          child: Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );

      if (_searchLocation != null) {
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: _searchLocation!,
            child: Icon(Icons.location_on, color: Colors.purple, size: 40),
          ),
        );
      }
    }

    List<Marker> combinedMarkers = List.from(markers)..addAll(_markers);

    return Container(
      height: 300,
      child: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(47.497913, 19.040236),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: combinedMarkers,
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Søg pladser',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          _searchPlaces(value);
        },
      ),
    );
  }
}

class PointOfInterest {
  final String name;
  final LatLng latLng;
  final String type;

  PointOfInterest({required this.name, required this.latLng, required this.type});
}

class Apartment {
  final String name;
  final String description;
  final String imageUrl;

  Apartment({required this.name, required this.description, required this.imageUrl});
}

class ApartmentWidget extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onTap;

  ApartmentWidget({required this.apartment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.network(
              apartment.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apartment.name,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  apartment.description,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApartmentDetailScreen extends StatelessWidget {
  final Apartment apartment;

  ApartmentDetailScreen({required this.apartment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(apartment.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(apartment.imageUrl, height: 200, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text(
              apartment.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(apartment.description, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}