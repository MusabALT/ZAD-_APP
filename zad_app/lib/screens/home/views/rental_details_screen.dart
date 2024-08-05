import 'package:flutter/material.dart';

import 'home_screen.dart';

class RentalDetailsScreen extends StatelessWidget {
  final String carName;
  final double totalPrice;
  final int rentalDays;
  final String paymentMethod;
  final String? cardNumber;
  final String uid;
  final String name;
  final bool discountApplied;
  final bool pointsAdded; // Add this parameter to indicate if points were added

  const RentalDetailsScreen({
    super.key,
    required this.carName,
    required this.totalPrice,
    required this.rentalDays,
    required this.paymentMethod,
    this.cardNumber,
    required this.uid,
    required this.name,
    this.discountApplied = false, // Default value is false
    this.pointsAdded = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 300),
              Text(
                'Car Name: $carName',
                style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              if (discountApplied) // Check if discount was applied
                const Text(
                  'You received a 30% discount!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              const SizedBox(height: 16.0),
              if (pointsAdded) // Check if points were added
                const Text(
                  'You have been given 200 points!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              const SizedBox(height: 16.0),
              Text(
                'Rental Days: $rentalDays',
                style: const TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Payment Method: $paymentMethod',
                style: const TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              if (paymentMethod == 'Card' && cardNumber != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      'Card Number: $cardNumber',
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              Text(
                'Name: $name',
                style: const TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              IconButton(
                icon: const Icon(
                  Icons.domain_verification_sharp,
                  color: Color.fromARGB(255, 38, 195, 6),
                  size: 100,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
