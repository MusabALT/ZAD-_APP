import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/car_list.dart';
import 'add_car_screen.dart';
import 'analytics_screen.dart';
import 'customer_feedback.dart';
import 'rentals.dart';
import 'return.dart';
import 'user_management_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

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
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/6.png',
                  scale: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '          ZAD',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: Colors.white,
                ),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Add a new car button
              _buildAnimatedButton(
                context,
                const AddCarScreen(),
                Icons.add,
                'Add a new car',
                const Color.fromARGB(255, 6, 160, 73),
              ),
              const SizedBox(height: 20),
              // Manage Cars button
              _buildAnimatedButton(
                context,
                const CarListScreen(),
                Icons.directions_car,
                'Manage Cars',
                const Color.fromARGB(255, 227, 209, 7),
              ),
              const SizedBox(height: 20),
              // Manage Reservations button
              _buildAnimatedButton(
                context,
                const AdminRentalManagementScreen(),
                Icons.directions_car,
                'Manage Reservations',
                const Color.fromARGB(255, 180, 115, 12),
              ),
              const SizedBox(height: 20),
              // View Analytics Reporting button
              _buildAnimatedButton(
                context,
                const AnalyticsScreen(),
                Icons.report,
                'View Analytics Reporting',
                Color.fromARGB(255, 21, 2, 53),
              ),
              const SizedBox(height: 20),
              // View Customer Feedback button
              /*_buildAnimatedButton(
                context,
                const FeedbackChart(feedbackData: []),
                Icons.report,
                'View Customer Feedback',
                const Color.fromARGB(255, 213, 200, 11),
              ),
              const SizedBox(height: 20),*/
              // Return Cars button
              _buildAnimatedButton(
                context,
                const ReturnAdminRentalManagementScreen(),
                Icons.report,
                'Return Cars',
                const Color.fromARGB(255, 213, 200, 11),
              ),
              const SizedBox(height: 20),
              // Manage Users button
              _buildAnimatedButton(
                context,
                const UserManagementScreen(),
                Icons.person,
                'Manage Users',
                const Color.fromARGB(255, 77, 182, 172),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context,
    Widget screen,
    IconData icon,
    String label,
    Color color,
  ) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 1000),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 50),
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
