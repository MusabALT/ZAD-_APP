import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRentalDetailsScreen extends StatefulWidget {
  const UserRentalDetailsScreen({super.key});

  @override
  _UserRentalDetailsScreenState createState() =>
      _UserRentalDetailsScreenState();
}

class _UserRentalDetailsScreenState extends State<UserRentalDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      body: user == null
          ? const Center(child: Text('Please log in to see your rentals'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('rentals')
                  .where('uid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rentals = snapshot.data!.docs;

                if (rentals.isEmpty) {
                  return const Center(child: Text('You have no rentals.'));
                }

                return ListView.builder(
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    var rental = rentals[index];
                    var rentalData = rental.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Car: ${rentalData['carName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Price: \$${rentalData['totalPrice']}'),
                            Text('Rental Days: ${rentalData['rentalDays']}'),
                            Text(
                                'Payment Method: ${rentalData['paymentMethod']}'),
                            if (rentalData['paymentMethod'] == 'Card' &&
                                rentalData['cardNumber'] != null)
                              Text('Card Number: ${rentalData['cardNumber']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RentalDetailsScreen(
                                  carName: rentalData['carName'],
                                  totalPrice: rentalData['totalPrice'],
                                  rentalDays: rentalData['rentalDays'],
                                  paymentMethod: rentalData['paymentMethod'],
                                  cardNumber: rentalData['cardNumber'],
                                  uid: rentalData['uid'],
                                  name: rentalData['name'],
                                ),
                              ),
                            );
                          },
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

class RentalDetailsScreen extends StatelessWidget {
  final String carName;
  final double totalPrice;
  final int rentalDays;
  final String paymentMethod;
  final String? cardNumber;
  final String uid;
  final String name;

  const RentalDetailsScreen({
    super.key,
    required this.carName,
    required this.totalPrice,
    required this.rentalDays,
    required this.paymentMethod,
    this.cardNumber,
    required this.uid,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car Name: $carName',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Rental Days: $rentalDays',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Payment Method: $paymentMethod',
              style: const TextStyle(fontSize: 20.0),
            ),
            if (paymentMethod == 'Card' && cardNumber != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Card Number: $cardNumber',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Text(
              'User ID: $uid',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Name: $name',
              style: const TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
