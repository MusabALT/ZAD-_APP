import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'SelectLocationScreen.dart';
import 'rental_details_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalPrice;
  final String carName;
  final int rentalDays;

  const PaymentScreen({
    super.key,
    required this.totalPrice,
    required this.carName,
    required this.rentalDays,
    required String uid,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Cash'; // Default payment method
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCVVController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  bool _usePoints = false; // Whether the user wants to use points
  String? _uid;
  String? _name;
  int? _userPoints;
  double? _userDiscount;
  late double _totalPrice; // Initialize _totalPrice in the constructor
  LatLng? _selectedLocation; // Variable to store selected location

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.totalPrice;
    _fetchUserIdAndName();
    _fetchUserPointsAndDiscount();
  }

  Future<void> _fetchUserIdAndName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });

      // Fetch the user's name from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'];
        });
      }
    }
  }

  Future<void> _fetchUserPointsAndDiscount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('memberships')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userPoints = userDoc['points'];
          _userDiscount = userDoc['discount']?.toDouble();
          if (_userDiscount != null && _userDiscount! > 0) {
            _totalPrice = _totalPrice * (1 - _userDiscount! / 100);
          }
        });
      }
    }
  }

  void _onPaymentMethodChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPaymentMethod = value;
      });
    }
  }

  void _onUsePointsChanged(bool? value) {
    if (value != null) {
      setState(() {
        _usePoints = value;
        if (_usePoints && _userPoints != null && _userPoints! >= 200) {
          _totalPrice = widget.totalPrice -
              (widget.totalPrice /
                  widget.rentalDays); // Subtract the cost of one day
        } else {
          _totalPrice = widget.totalPrice;
        }
      });
    }
  }

  Future<void> _submitPayment() async {
    bool discountApplied = false;
    bool pointsAdded = false;

    if (_uid == null) {
      // Handle the case where user ID is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is not available')),
      );
      return;
    }

    if (_usePoints && _userPoints != null && _userPoints! >= 200) {
      // Deduct points from user's account
      int updatedPoints = _userPoints! - 200;
      await FirebaseFirestore.instance
          .collection('memberships')
          .doc(_uid)
          .update({'points': updatedPoints});

      // Show alert for free day
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
                  'You have been given one free day because you used your points!',
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
    }

    if (_userDiscount != null && _userDiscount! > 0) {
      discountApplied = true;

      // Show alert for discount applied
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
                  'Your discount has been applied!',
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
    }

    // Save rental information to Firestore
    await FirebaseFirestore.instance.collection('rentals').add({
      'carName': widget.carName,
      'uid': _uid,
      'name': _name,
      'totalPrice': _totalPrice,
      'rentalDays': widget.rentalDays,
      'paymentMethod': _selectedPaymentMethod,
      'cardNumber':
          _selectedPaymentMethod == 'Card' ? _cardNumberController.text : null,
      'cardExpiry':
          _selectedPaymentMethod == 'Card' ? _cardExpiryController.text : null,
      'cardCVV':
          _selectedPaymentMethod == 'Card' ? _cardCVVController.text : null,
      'cardHolderName': _selectedPaymentMethod == 'Card'
          ? _cardHolderNameController.text
          : null,
      'location': _selectedLocation != null
          ? GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude)
          : null, // Save selected location
    });

    // Add 200 points to the user's account
    if (_userPoints != null) {
      int updatedPoints = _userPoints! + 200;
      await FirebaseFirestore.instance
          .collection('memberships')
          .doc(_uid)
          .update({'points': updatedPoints});
      pointsAdded = true;
    }

    // Navigate to RentalDetailsScreen and prevent going back
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RentalDetailsScreen(
          carName: widget.carName,
          uid: _uid!,
          name: _name!,
          totalPrice: _totalPrice,
          rentalDays: widget.rentalDays,
          paymentMethod: _selectedPaymentMethod,
          cardNumber: _selectedPaymentMethod == 'Card'
              ? _cardNumberController.text
              : null,
          discountApplied: discountApplied,
          pointsAdded: pointsAdded,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _selectLocation() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
    );
    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Price: \$$_totalPrice',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            if (_userPoints != null && _userPoints! >= 200) ...[
              CheckboxListTile(
                title: const Text(
                  'Use 200 points for one free day',
                  style: TextStyle(color: Colors.white),
                ),
                value: _usePoints,
                onChanged: _onUsePointsChanged,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              const SizedBox(height: 16.0),
            ],
            const Text(
              'Select Payment Method:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              title: const Text('Cash', style: TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: 'Cash',
                groupValue: _selectedPaymentMethod,
                onChanged: _onPaymentMethodChanged,
                activeColor: Colors.white,
              ),
            ),
            ListTile(
              title: const Text('Card', style: TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: 'Card',
                groupValue: _selectedPaymentMethod,
                onChanged: _onPaymentMethodChanged,
                activeColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            if (_selectedPaymentMethod == 'Card') ...[
              TextField(
                controller: _cardHolderNameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
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
              const SizedBox(height: 8.0),
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
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
              const SizedBox(height: 8.0),
              TextField(
                controller: _cardExpiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _cardCVVController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),
            ],
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 40, 231),
              ),
              child: const Text('Select Location',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 40, 231),
              ),
              child: const Text('Submit Payment',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
