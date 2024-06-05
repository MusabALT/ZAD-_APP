import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/car_list.dart';
import 'add_car_screen.dart';
import 'rentals.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 66, 12, 190),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/6.png',
                scale: 2,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                '          ZAD',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Colors.white),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Add a new car button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddCarScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add a new car'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 6, 160, 73),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              // Manage Cars button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CarListScreen()),
                  );
                },
                icon: const Icon(Icons.directions_car),
                label: const Text('Manage Cars'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 227, 209, 7),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AdminRentalManagementScreen()),
                  );
                },
                icon: const Icon(Icons.directions_car),
                label: const Text('Manage Reservations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 180, 115, 12),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              // View Reports button
              ElevatedButton.icon(
                onPressed: () {
                  // View reports logic
                },
                icon: const Icon(Icons.report),
                label: const Text('View Reports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 213, 200, 11),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
