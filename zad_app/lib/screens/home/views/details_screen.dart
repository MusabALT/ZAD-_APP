import 'package:flutter/material.dart';
import 'package:zad_app/models/car_model.dart';
import 'package:zad_app/screens/home/views/BookingScreen.dart';

class DetailsScreen extends StatelessWidget {
  final Car car;

  const DetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: Row(
          children: [
            Image.asset('assets/6.png', scale: 2),
            const SizedBox(width: 8),
            const Text(
              '       ZAD',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  car.imagePath, // Ensure this matches your Car model's image URL property
                  height: 200, // Set desired height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/placeholder.png', // Your local placeholder image
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                car.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Model Year: ${car.modelYear}',
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              Text(
                'Fuel: ${car.fuel}%',
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              Text(
                'Availability: ${car.availability}',
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              Text(
                'Price: \$${car.price}',
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              Text(
                'Old Price: \$${car.oldPrice}',
                style: const TextStyle(
                  fontSize: 16.0,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              ...[
                'Air Conditioning',
                'Power Windows',
                'Bluetooth Connectivity',
                'Cruise Control',
                'Rear-View Camera'
              ].map((feature) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8.0),
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 15, 40, 231),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          carPricePerDay: car.price,
                          carId: car.id, // Pass the carId here
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
