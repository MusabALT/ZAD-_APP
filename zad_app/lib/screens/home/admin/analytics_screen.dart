import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Customer Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 300, child: CustomerFeedbackChart()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Car Rental Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 300, child: CarRentalStatsChart()),
          ],
        ),
      ),
    );
  }
}

class CustomerFeedbackChart extends StatelessWidget {
  const CustomerFeedbackChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No feedback data found'));
        }

        final feedbackData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return FeedbackModel(
            carName: data['carName'],
            rating: data['rating'],
          );
        }).toList();

        final feedbackSeries = [
          charts.Series<FeedbackModel, String>(
            id: 'Feedback',
            domainFn: (FeedbackModel feedback, _) => feedback.carName,
            measureFn: (FeedbackModel feedback, _) => feedback.rating,
            data: feedbackData,
          ),
        ];

        return charts.BarChart(
          feedbackSeries,
          animate: true,
        );
      },
    );
  }
}

class CarRentalStatsChart extends StatelessWidget {
  const CarRentalStatsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rentals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No rental data found'));
        }

        final rentalData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return RentalModel(
            carName: data['carName'],
            totalPrice: data['totalPrice'],
          );
        }).toList();

        final rentalSeries = [
          charts.Series<RentalModel, String>(
            id: 'Rentals',
            domainFn: (RentalModel rental, _) => rental.carName,
            measureFn: (RentalModel rental, _) => rental.totalPrice,
            data: rentalData,
          ),
        ];

        return charts.BarChart(
          rentalSeries,
          animate: true,
        );
      },
    );
  }
}

class FeedbackModel {
  final String carName;
  final double rating;

  FeedbackModel({required this.carName, required this.rating});
}

class RentalModel {
  final String carName;
  final double totalPrice;

  RentalModel({required this.carName, required this.totalPrice});
}
