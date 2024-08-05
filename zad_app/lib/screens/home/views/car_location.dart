import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

class CarLocationScreen extends StatefulWidget {
  const CarLocationScreen({super.key});

  @override
  _CarLocationScreenState createState() => _CarLocationScreenState();
}

class _CarLocationScreenState extends State<CarLocationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  LatLng _carLocation = const LatLng(37.7749, -122.4194); // Default location
  LatLng _userLocation = const LatLng(37.7749, -122.4194); // Default location
  bool _isLoading = true;
  late BitmapDescriptor _carIcon;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _createCarIcon();
  }

  Future<void> _createCarIcon() async {
    _carIcon = await _bitmapDescriptorFromIcon(
        Icons.directions_car, const Color.fromARGB(255, 45, 3, 101));
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromIcon(
      IconData iconData, Color color) async {
    final PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 48.0;
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);
    final textSpan = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );

    textPainter.text = textSpan;
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
    final image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _fetchLocations();
    } else {
      print('Location permission denied');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLocations() async {
    await _fetchCarLocation();
    await _fetchUserLocation();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchCarLocation() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('rentals').doc(user.uid).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          if (data['carLocation'] != null) {
            setState(() {
              _carLocation = LatLng(
                  data['carLocation'].latitude, data['carLocation'].longitude);
            });
            print('Car location fetched: $_carLocation');
          } else {
            // Set default location if not already set
            await _saveCarLocation(
                _carLocation.latitude, _carLocation.longitude);
          }
        } else {
          // Set default location if document does not exist
          await _saveCarLocation(_carLocation.latitude, _carLocation.longitude);
        }
      } else {
        print('No user logged in.');
      }
    } catch (e) {
      print('Error fetching car location: $e');
    }
  }

  Future<void> _saveCarLocation(double latitude, double longitude) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('rentals').doc(user.uid).set({
        'carLocation': GeoPoint(latitude, longitude),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      print('User location fetched: $_userLocation');
    } catch (e) {
      print('Error fetching user location: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print('Map created');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text(
          'Car Location',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: () async {
              Position position = await _determinePosition();
              setState(() {
                _carLocation = LatLng(position.latitude, position.longitude);
              });
              await _saveCarLocation(position.latitude, position.longitude);
              print('Car location updated: $_carLocation');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('carMarker'),
                  position: _carLocation,
                  icon: _carIcon, // Use the custom car icon here
                  infoWindow: const InfoWindow(
                    title: 'Your Car',
                  ),
                ),
                Marker(
                  markerId: const MarkerId('userMarker'),
                  position: _userLocation,
                  infoWindow: const InfoWindow(
                    title: 'Your Location',
                  ),
                ),
              },
            ),
    );
  }
}
