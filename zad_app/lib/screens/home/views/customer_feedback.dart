import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CustomerFeedbackScreen extends StatelessWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              rating: data['rating'].toDouble(),
            );
          }).toList();

          final feedbackSeries = [
            charts.Series<FeedbackModel, String>(
              id: 'Feedback',
              domainFn: (FeedbackModel feedback, _) => feedback.carName,
              measureFn: (FeedbackModel feedback, _) => feedback.rating,
              data: feedbackData,
              labelAccessorFn: (FeedbackModel feedback, _) =>
                  '${feedback.carName}: ${feedback.rating}',
              colorFn: (_, __) =>
                  charts.MaterialPalette.blue.shadeDefault, // Customize color
            ),
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: charts.BarChart(
              feedbackSeries,
              animate: true,
              vertical: false,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: const charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 12, color: charts.MaterialPalette.white),
              )),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                    fontSize: 12, color: charts.MaterialPalette.white),
              )),
            ),
          );
        },
      ),
    );
  }
}

class FeedbackModel {
  final String carName;
  final double rating;

  FeedbackModel({required this.carName, required this.rating});
}
