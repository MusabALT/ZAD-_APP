import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String name;
  final String imagePath;
  final int fuel;
  final int modelYear;
  final String availability;
  final double price;
  final double oldPrice;
  final bool isBooked;

  Car({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.fuel,
    required this.modelYear,
    required this.availability,
    required this.price,
    required this.oldPrice,
    required this.isBooked,
  });

  // Factory method to create a Car object from Firestore data
  factory Car.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      imagePath: data['image_path'] ??
          'car_images/placeholder.png', // Default placeholder path
      fuel: int.tryParse(data['fuel'].toString()) ?? 0,
      modelYear: int.tryParse(data['model_year'].toString()) ?? 0,
      availability: data['availability'] ?? 'Unavailable',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      oldPrice: double.tryParse(data['old_price'].toString()) ?? 0.0,
      isBooked: data['is_booked'] ?? false,
    );
  }

  // Method to convert a Car object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image_path': imagePath,
      'fuel': fuel,
      'model_year': modelYear,
      'availability': availability,
      'price': price,
      'old_price': oldPrice,
      'is_booked': isBooked,
    };
  }
}

Future<Car> fetchCarDetails(String carId) async {
  final doc =
      await FirebaseFirestore.instance.collection('cars').doc(carId).get();
  return Car.fromDocument(doc);
}
