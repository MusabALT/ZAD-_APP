import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String role;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }
}

Future<void> bookRental(String carId, double price, int days,
    String paymentMethod, String? cardNumber) async {
  // Get the current user's ID
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    throw Exception('User must be logged in to book a rental');
  }

  // Create a new rental document with user ID
  await FirebaseFirestore.instance.collection('rentals').add({
    'uid': uid,
    'carId': carId,
    'totalPrice': price * days, // Example of calculating total price
    'rentalDays': days,
    'paymentMethod': paymentMethod,
    'cardNumber': paymentMethod == 'Card'
        ? cardNumber
        : null, // Only include card number if payment is by card
    'createdDate': FieldValue
        .serverTimestamp(), // Adds a server timestamp for when the rental was booked
  });
}
