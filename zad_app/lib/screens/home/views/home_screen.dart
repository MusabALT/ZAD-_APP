import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zad_app/screens/auth/view/sign_in_screen.dart';
import 'package:zad_app/screens/home/views/Search.dart';
import 'package:zad_app/screens/home/views/membership_screen.dart';

import '../../../Controller/auth_controller.dart';
import 'car_location.dart';
import 'feedback_submission_screen.dart';
import 'profile.dart';
import 'veiw_rental_information.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Keeps track of the selected index
  final AuthController _authController =
      AuthController(); // Instantiate the AuthController

  late AnimationController _animationController;
  late Animation<double> _animation;

  static final List<Widget> _widgetOptions = <Widget>[
    const SearchScreen(), // First screen
    const MembershipScreen(),
    const UserRentalDetailsScreen(),
    const CarLocationScreen(),
    const FeedbackSubmissionScreen(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _logout() async {
    await _authController.logout(); // Call your logout method
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  Future<bool> _onWillPop() async {
    await _authController.logout(); // Log out user on back press
    return true; // Allow the pop action to proceed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () => _signOut(context), // Pass the context to _signOut
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.search),
            label: 'Search For Car',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.card_membership),
            label: 'Membership',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.car_crash),
            label: 'View Rental Details',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.location_pin),
            label: 'Location Tracker',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.rate_review_rounded),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 66, 12, 190),
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            const Color.fromARGB(255, 140, 106, 220), // Color for selected item
        unselectedItemColor: const Color.fromARGB(
            255, 154, 134, 199), // Color for unselected items
        onTap: _onItemTapped,
      ),
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, "/login");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
