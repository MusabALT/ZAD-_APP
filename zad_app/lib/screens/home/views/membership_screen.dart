import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MembershipScreen(),
    );
  }
}

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  Future<bool> hasMembership() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('memberships')
        .doc(userId)
        .get();

    return userDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const MembershipCard(
              title: 'Premium Membership',
              benefits: [
                'Collect Loyalty Points',
                'Get A Discount When You Rent The Car',
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isMember = await hasMembership();
                if (isMember) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const PointsScreen()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'You must apply for a membership to view points',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 190, 251, 23),
              ),
              child: const Text('View Points'),
            ),
          ],
        ),
      ),
    );
  }
}

class MembershipCard extends StatelessWidget {
  final String title;
  final List<String> benefits;

  const MembershipCard(
      {super.key, required this.title, required this.benefits});

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> applyMembership(BuildContext context) async {
    String? userId = await getCurrentUserId();

    if (userId == null) {
      // Handle the case when the user is not logged in
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'You must be logged in to apply for a membership',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    // Check if the user already has a membership
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('memberships')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      // Show already applied dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'You already have a membership',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Save membership data to Firebase
      await FirebaseFirestore.instance
          .collection('memberships')
          .doc(userId)
          .set({'membership': title, 'points': 0, 'discount': 0});

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Successfully Applied',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const PointsScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            for (var benefit in benefits)
              Row(
                children: <Widget>[
                  const Icon(Icons.check, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            const Text(
              '* Earn 500 points to get a 30% discount!',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                applyMembership(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 119, 225, 151),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  Future<int?> getUserPoints() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('memberships')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc['points'] ?? 0;
    }
    return 0;
  }

  Future<void> claimDiscount(BuildContext context) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('memberships')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      int currentPoints = userDoc['points'] ?? 0;
      if (currentPoints >= 500) {
        // Save discount data to Firebase and decrease points by 500
        await FirebaseFirestore.instance
            .collection('memberships')
            .doc(userId)
            .update({'discount': 30, 'points': currentPoints - 500});

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You have received a 30% discount!',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Not enough points to claim a discount.',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      body: Center(
        child: FutureBuilder<int?>(
          future: getUserPoints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('You have no points.');
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'You Have : ${snapshot.data} Points',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 30),
                const Text(
                  '500 points to get a 30% discount!',
                  style: TextStyle(
                      color: Color.fromARGB(255, 222, 207, 9),
                      fontSize: 15,
                      backgroundColor: Colors.deepPurple),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    claimDiscount(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 4, 91),
                  ),
                  child: const Text(
                    'Claim Redemption',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
