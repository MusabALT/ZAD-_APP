import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  late String name, fuel, modelYear, availability, price, oldPrice;
  XFile? _carImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _carImage = image;
      });
    }
  }

  Future<String> _uploadImage(XFile image) async {
    Reference storageReference =
        _storage.ref().child('car_images/${image.name}');
    UploadTask uploadTask = storageReference.putFile(File(image.path));
    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  Future<void> _addCar() async {
    if (_carImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a car image')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = await _uploadImage(_carImage!);

        await _firestore.collection('cars').add({
          'name': name,
          'image_path': imageUrl,
          'fuel': int.parse(fuel),
          'model_year': int.parse(modelYear),
          'availability': availability,
          'price': double.parse(price),
          'old_price': double.parse(oldPrice),
          'is_booked': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully')),
        );

        setState(() {
          _carImage = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add car: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text(
          'Add Car',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) => name = value,
                decoration: const InputDecoration(
                  labelText: 'Car Name',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car name';
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                onChanged: (value) => fuel = value,
                decoration: const InputDecoration(
                  labelText: 'Fuel Percentage',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fuel percentage';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) => modelYear = value,
                decoration: const InputDecoration(
                  labelText: 'Model Year',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter model year';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) => availability = value,
                decoration: const InputDecoration(
                  labelText: 'Availability',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter availability';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) => price = value,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) => oldPrice = value,
                decoration: const InputDecoration(
                  labelText: 'Old Price',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter old price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Car Image'),
              ),
              const SizedBox(height: 10),
              _carImage == null
                  ? const Text('No image selected')
                  : Image.file(File(_carImage!.path)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCar,
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
