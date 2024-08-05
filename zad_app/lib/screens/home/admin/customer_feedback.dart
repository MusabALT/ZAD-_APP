import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomerFeedbackSection extends StatelessWidget {
  const CustomerFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
            return const Center(child: Text('No feedback data available'));
          }

          final feedbackData = snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Customer Feedback',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FeedbackChart(feedbackData: feedbackData),
            ],
          );
        },
      ),
    );
  }
}

class FeedbackChart extends StatelessWidget {
  
  final List<Map<String, dynamic>> feedbackData;

  const FeedbackChart({super.key, required this.feedbackData});

  List<BarChartGroupData> _buildBarChartData() {
    List<String> categories = ['Experience', 'Price', 'Condition', 'App'];
    Map<String, List<double>> categoryRatings = {
      'Experience': [],
      'Price': [],
      'Condition': [],
      'App': []
    };

    for (var data in feedbackData) {
      for (var category in categories) {
        var rating = data['${category.toLowerCase()}Rating'];
        if (rating != null) {
          categoryRatings[category]?.add(rating.toDouble());
        }
      }
    }

    return List.generate(categories.length, (index) {
      final category = categories[index];
      final ratings = categoryRatings[category] ?? [];
      final averageRating = ratings.isNotEmpty
          ? ratings.reduce((a, b) => a + b) / ratings.length
          : 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: averageRating > 0
                ? averageRating
                : 0.5, // Ensure there's a minimum height
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        barGroups: _buildBarChartData(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1.0,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5, // Ensuring grid lines are visible
            );
          },
        ),
        titlesData: FlTitlesData(
          
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Reserve more space for titles
              getTitlesWidget: (value, meta) {
                final categoryIndex = value.toInt();
                final categories = ['Experience', 'Price', 'Condition', 'App'];
                if (categoryIndex >= 0 && categoryIndex < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Adjust spacing
                    child: Column(
                      children: [
                        Text(
                          categories[categoryIndex],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                14, // Adjust font size for better visibility
                          ),
                        ),
                        const Text(
                          'Rating',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Smaller font size for "Rating"
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Adjust font size for better visibility
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }
}
