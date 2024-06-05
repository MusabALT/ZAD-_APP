import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:camera/camera.dart';
import '../../../models/car_model.dart';
import 'payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final double carPricePerDay;
  final String carId;

  const BookingScreen(
      {super.key, required this.carPricePerDay, required this.carId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  XFile? _licenseImage;
  XFile? _userImage;
  bool _isFaceDetectedInLicense = false;
  bool _isFaceDetectedInUser = false;
  bool _facesMismatch = false;
  String? _extractedName;
  CameraController? _cameraController;
  double _totalPrice = 0.0;
  Car? _car;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _daysController.addListener(_calculateTotalPrice);
    _fetchCarDetails();
  }

  Future<void> _fetchCarDetails() async {
    final car = await fetchCarDetails(widget.carId);
    setState(() {
      _car = car;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
  }

  void _calculateTotalPrice() {
    final days = int.tryParse(_daysController.text) ?? 0;
    setState(() {
      _totalPrice = days * widget.carPricePerDay;
    });
  }

  Future<void> _selectLicenseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final FaceDetector faceDetector = GoogleVision.instance.faceDetector();
      final GoogleVisionImage visionImage =
          GoogleVisionImage.fromFile(File(image.path));
      final List<Face> faces = await faceDetector.processImage(visionImage);
      final TextRecognizer textRecognizer =
          GoogleVision.instance.textRecognizer();
      final VisionText visionText =
          await textRecognizer.processImage(visionImage);

      _extractedName =
          _extractText(visionText); // Assuming we are extracting name

      setState(() {
        _licenseImage = image;
        _isFaceDetectedInLicense = faces.isNotEmpty;
      });
    }
  }

  String? _extractText(VisionText visionText) {
    for (TextBlock block in visionText.blocks) {
      if (block.text != null && block.text!.contains('Name')) {
        return block.text!.split('Name').last.trim();
      }
    }
    return null;
  }

  Future<void> _takePicture() async {
    if (_cameraController == null) {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController!.initialize();
    }

    final XFile image = await _cameraController!.takePicture();
    final FaceDetector faceDetector = GoogleVision.instance.faceDetector();
    final List<Face> faces = await faceDetector
        .processImage(GoogleVisionImage.fromFile(File(image.path)));

    bool facesMatch = _compareFaces(faces);

    setState(() {
      _userImage = image;
      _isFaceDetectedInUser = faces.isNotEmpty;
      _facesMismatch = !facesMatch;
    });
  }

  bool _compareFaces(List<Face> faces) {
    return true;
  }

  Future<void> _bookCar() async {
    try {
      // Update the car document in Firestore to set `is_booked` to true
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .update({'is_booked': true});

      // Navigate to the payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            totalPrice: _totalPrice,
            carName: _car!.name,
            rentalDays: int.tryParse(_daysController.text) ?? 0, uid: '',
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to book car: $e',
                style: const TextStyle(color: Colors.white))),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _daysController.removeListener(_calculateTotalPrice);
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        title: const Text('Booking Information',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      ),
      body: _car == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload License and Take a Photo',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _selectLicenseImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _licenseImage == null
                              ? const Icon(Icons.upload_file,
                                  size: 50, color: Colors.white)
                              : Stack(
                                  children: [
                                    Image.file(
                                      File(_licenseImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                    if (!_isFaceDetectedInLicense)
                                      const Center(
                                        child: Text(
                                          'No face detected',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _userImage == null
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.white)
                              : Stack(
                                  children: [
                                    Image.file(
                                      File(_userImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                    if (!_isFaceDetectedInUser)
                                      const Center(
                                        child: Text(
                                          'No face detected',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (_facesMismatch)
                    const Center(
                      child: Text(
                        'Faces do not match',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText:
                          'Enter your address as on license for verification',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Days',
                      hintText: 'Enter number of rental days',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Total Price: \$$_totalPrice',
                    style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 15, 40, 231),
                      ),
                      onPressed: _bookCar,
                      child: const Text(
                        'Payment',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
