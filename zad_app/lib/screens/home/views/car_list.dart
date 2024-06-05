import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/car_model.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        title: const Text('Car List', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No cars available',
                    style: TextStyle(color: Colors.white)));
          }
          final carDocs = snapshot.data!.docs;
          final cars = carDocs.map((doc) => Car.fromDocument(doc)).toList();

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                leading: Image.network(car.imagePath,
                    width: 50, height: 50, fit: BoxFit.cover),
                title:
                    Text(car.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${car.modelYear} - ${car.availability}',
                    style: const TextStyle(color: Colors.white)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCarScreen(car: car),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('cars')
                            .doc(car.id)
                            .delete();
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Handle car tap if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditCarScreen extends StatefulWidget {
  final Car car;

  const EditCarScreen({super.key, required this.car});

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  late TextEditingController _nameController;
  late TextEditingController _modelYearController;
  late TextEditingController _availabilityController;
  late TextEditingController _priceController;
  late TextEditingController _imagePathController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.car.name);
    _modelYearController =
        TextEditingController(text: widget.car.modelYear.toString());
    _availabilityController =
        TextEditingController(text: widget.car.availability);
    _priceController = TextEditingController(text: widget.car.price.toString());
    _imagePathController = TextEditingController(text: widget.car.imagePath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelYearController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  Future<void> _updateCar() async {
    await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.car.id)
        .update({
      'name': _nameController.text,
      'modelYear': int.parse(_modelYearController.text),
      'availability': _availabilityController.text,
      'price': double.parse(_priceController.text),
      'imagePath': _imagePathController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text('Edit Car',
            style: TextStyle(color: Color.fromARGB(255, 230, 225, 241))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Car Name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _modelYearController,
              decoration: const InputDecoration(
                labelText: 'Model Year',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _availabilityController,
              decoration: const InputDecoration(
                labelText: 'Availability',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _imagePathController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateCar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Update Car',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
