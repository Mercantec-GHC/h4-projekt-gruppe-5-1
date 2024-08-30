import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'dart:io' show Platform;

class RenterHomepage extends StatefulWidget {
  @override
  _RenterHomePageState createState() => _RenterHomePageState();
}

class _RenterHomePageState extends State<RenterHomepage> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentLocation != null) {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=10'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);
      } else {
        throw Exception('Failed to load places');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLejlighederSection(),
              SizedBox(height: 20),
              _buildPointsOfInterestSection(),
              SizedBox(height: 20),
              _buildMapSection(),
              SizedBox(height: 20),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLejlighederSection() {
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
            'Lejligheder',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 15),
          _buildApartmentRow(),
          SizedBox(height: 20),
          _buildApartmentRow(),
        ],
      ),
    );
  }

  Widget _buildApartmentRow() {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text for Image 1',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'More text for image 1',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
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
            'Points of interest',
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 15),
          _buildPointsOfInterestRow(),
          SizedBox(height: 20),
          _buildPointsOfInterestRow(),
        ],
      ),
    );
  }

  Widget _buildPointsOfInterestRow() {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text for image 1',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Text for image 1',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
  return Container(
    height: 300,
    child: _currentLocation == null
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(47.497913, 19.040236),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!,
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
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
          labelText: 'Search Places',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          _searchPlaces(value);
        },
      ),
    );
  }
}
