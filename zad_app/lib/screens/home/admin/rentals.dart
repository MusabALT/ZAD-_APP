import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminRentalManagementScreen extends StatefulWidget {
  const AdminRentalManagementScreen({super.key});

  @override
  _AdminRentalManagementScreenState createState() =>
      _AdminRentalManagementScreenState();
}

class _AdminRentalManagementScreenState
    extends State<AdminRentalManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteRental(String rentalId, String? carId) async {
    await _firestore.collection('rentals').doc(rentalId).delete();
    if (carId != null) {
      await _firestore.collection('cars').doc(carId).update({
        'is_booked': false,
        'availability': 'In Stock',
      });
    }
  }

  Future<void> _updateRental(
      String rentalId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('rentals').doc(rentalId).update(updatedData);
  }

  Future<void> _returnCar(String rentalId, String carId) async {
    await _firestore.collection('rentals').doc(rentalId).update({
      'returned': true,
    });
    await _firestore.collection('cars').doc(carId).update({
      'is_booked': false,
      'availability': 'In Stock',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text('Admin Rental Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('rentals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              var rental = rentals[index];
              var rentalData = rental.data() as Map<String, dynamic>;

              String imagePath = rentalData['carImage'] ?? '';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        )
                      : const Icon(Icons.car_rental),
                  title: Text('Car: ${rentalData['carName'] ?? 'N/A'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${rentalData['name'] ?? 'N/A'}'),
                      Text(
                          'Total Price: \$${rentalData['totalPrice'] ?? 'N/A'}'),
                      Text('Rental Days: ${rentalData['rentalDays'] ?? 'N/A'}'),
                      Text(
                          'Payment Method: ${rentalData['paymentMethod'] ?? 'N/A'}'),
                      if (rentalData['paymentMethod'] == 'Card' &&
                          rentalData['cardNumber'] != null)
                        Text(
                            'Card Number: ${rentalData['cardNumber'] ?? 'N/A'}'),
                      if (rentalData['location'] != null)
                        Text(
                            'Location: (${rentalData['location'].latitude}, ${rentalData['location'].longitude})'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Handle rental update
                          _showUpdateDialog(rental.id, rentalData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Handle rental deletion
                          _deleteRental(rental.id, rentalData['carId']);
                        },
                      ),
                      if (rentalData['location'] != null)
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            // Show the car location on a map
                            _showMapDialog(rentalData['location'].latitude,
                                rentalData['location'].longitude);
                          },
                        ),
                      if (rentalData['carId'] != null &&
                          (rentalData['returned'] == null ||
                              rentalData['returned'] == false))
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: () {
                            // Handle returning the car
                            _returnCar(rental.id, rentalData['carId']);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUpdateDialog(String rentalId, Map<String, dynamic> rentalData) {
    final TextEditingController carNameController =
        TextEditingController(text: rentalData['carName']);
    final TextEditingController totalPriceController =
        TextEditingController(text: rentalData['totalPrice'].toString());
    final TextEditingController rentalDaysController =
        TextEditingController(text: rentalData['rentalDays'].toString());
    final TextEditingController paymentMethodController =
        TextEditingController(text: rentalData['paymentMethod']);
    final TextEditingController cardNumberController =
        TextEditingController(text: rentalData['cardNumber']);
    final TextEditingController latitudeController = TextEditingController(
        text: rentalData['location'] != null
            ? rentalData['location'].latitude.toString()
            : '');
    final TextEditingController longitudeController = TextEditingController(
        text: rentalData['location'] != null
            ? rentalData['location'].longitude.toString()
            : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Rental'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: carNameController,
                  decoration: const InputDecoration(labelText: 'Car Name'),
                ),
                TextField(
                  controller: totalPriceController,
                  decoration: const InputDecoration(labelText: 'Total Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rentalDaysController,
                  decoration: const InputDecoration(labelText: 'Rental Days'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: paymentMethodController,
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                ),
                if (paymentMethodController.text == 'Card')
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(labelText: 'Card Number'),
                  ),
                TextField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  'carName': carNameController.text,
                  'totalPrice': double.parse(totalPriceController.text),
                  'rentalDays': int.parse(rentalDaysController.text),
                  'paymentMethod': paymentMethodController.text,
                  'cardNumber': paymentMethodController.text == 'Card'
                      ? cardNumberController.text
                      : null,
                  'location': GeoPoint(
                    double.parse(latitudeController.text),
                    double.parse(longitudeController.text),
                  ),
                };
                _updateRental(rentalId, updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showMapDialog(double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Car Location'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('location'),
                  position: LatLng(latitude, longitude),
                ),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
