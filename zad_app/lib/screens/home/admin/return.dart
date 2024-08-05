import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnAdminRentalManagementScreen extends StatefulWidget {
  const ReturnAdminRentalManagementScreen({super.key});

  @override
  _ReturnAdminRentalManagementScreenState createState() =>
      _ReturnAdminRentalManagementScreenState();
}

class _ReturnAdminRentalManagementScreenState
    extends State<ReturnAdminRentalManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _returnCar(String rentalId, String carName) async {
    try {
      // Find the car document by car name
      QuerySnapshot carSnapshot = await _firestore
          .collection('cars')
          .where('name', isEqualTo: carName)
          .get();

      if (carSnapshot.docs.isNotEmpty) {
        String carId = carSnapshot.docs.first.id;

        // Update the car's is_booked status and availability
        await _firestore.collection('cars').doc(carId).update({
          'is_booked': false,
          'availability': 'In Stock',
        });

        // Delete the rental document
        await _firestore.collection('rentals').doc(rentalId).delete();

        // Show success alert
        _showAlert('Car returned and rental removed successfully');
      } else {
        _showAlert('Car not found');
      }
    } catch (e) {
      // Show error alert
      _showAlert('Error returning car: $e');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notification'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text(''),
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

              String carName = rentalData['carName'] ?? '';
              bool isBooked = rentalData['is_booked'] ?? true;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.car_rental),
                  title: Text('Car: $carName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${rentalData['name'] ?? 'N/A'}'),
                      Text(
                          'Total Price: \$${rentalData['totalPrice'] ?? 'N/A'}'),
                      Text('Rental Days: ${rentalData['rentalDays'] ?? 'N/A'}'),
                      Text(
                          'Payment Method: ${rentalData['paymentMethod'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: () {
                          // Handle returning the car
                          if (isBooked) {
                            _returnCar(rental.id, carName);
                          } else {
                            _showAlert('Car is already returned');
                          }
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
}
