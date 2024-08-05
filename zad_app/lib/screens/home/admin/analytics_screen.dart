import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int totalUsers = 0;
  int totalRentals = 0;
  int totalMemberships = 0;
  int totalBookings = 0;
  int totalCustomers = 0;
  double averageBookingDuration = 0.0;
  List<FlSpot> userTrend = [];
  List<FlSpot> rentalTrend = [];
  List<FlSpot> membershipTrend = [];
  List<FlSpot> bookingTrends = [];
  List<FlSpot> predictedUserTrend = [];
  List<FlSpot> predictedRentalTrend = [];
  List<FlSpot> predictedMembershipTrend = [];
  List<FlSpot> predictedBookingTrends = [];
  List<String> recommendations = [];

  double averageExperienceRating = 0.0;
  double averagePriceRating = 0.0;
  double averageConditionRating = 0.0;
  double averageAppRating = 0.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
    fetchTrendData();
    fetchBookingAnalyticsData();
    fetchFeedbackData();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchAnalyticsData() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    final rentalsSnapshot =
        await FirebaseFirestore.instance.collection('rentals').get();
    final membershipsSnapshot =
        await FirebaseFirestore.instance.collection('memberships').get();

    setState(() {
      totalUsers = usersSnapshot.size;
      totalRentals = rentalsSnapshot.size;
      totalMemberships = membershipsSnapshot.size;
    });
  }

  Future<void> fetchBookingAnalyticsData() async {
    final bookingsSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();
    final customersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    double totalDuration = 0.0;

    for (var doc in bookingsSnapshot.docs) {
      totalDuration += doc['days'];
    }

    setState(() {
      totalBookings = bookingsSnapshot.size;
      totalCustomers = customersSnapshot.size;
      averageBookingDuration = bookingsSnapshot.size > 0
          ? totalDuration / bookingsSnapshot.size
          : 0.0;
    });
  }

  Future<void> fetchFeedbackData() async {
    final feedbackSnapshot =
        await FirebaseFirestore.instance.collection('feedback').get();

    double totalExperienceRating = 0.0;
    double totalPriceRating = 0.0;
    double totalConditionRating = 0.0;
    double totalAppRating = 0.0;

    for (var doc in feedbackSnapshot.docs) {
      totalExperienceRating += doc['experienceRating'];
      totalPriceRating += doc['priceRating'];
      totalConditionRating += doc['conditionRating'];
      totalAppRating += doc['appRating'];
    }

    int feedbackCount = feedbackSnapshot.size;
    if (feedbackCount > 0) {
      setState(() {
        averageExperienceRating = totalExperienceRating / feedbackCount;
        averagePriceRating = totalPriceRating / feedbackCount;
        averageConditionRating = totalConditionRating / feedbackCount;
        averageAppRating = totalAppRating / feedbackCount;
      });
    }
  }

  Future<void> fetchTrendData() async {
    // Fetch actual data from Firestore and then call predictTrends
    setState(() {
      userTrend = [
        FlSpot(0, 10),
        FlSpot(1, 20),
        FlSpot(2, 30),
        FlSpot(3, 40),
        FlSpot(4, 50),
      ];
      rentalTrend = [
        FlSpot(0, 5),
        FlSpot(1, 15),
        FlSpot(2, 25),
        FlSpot(3, 35),
        FlSpot(4, 45),
      ];
      membershipTrend = [
        FlSpot(0, 2),
        FlSpot(1, 8),
        FlSpot(2, 18),
        FlSpot(3, 28),
        FlSpot(4, 38),
      ];
      bookingTrends = [
        FlSpot(0, 10),
        FlSpot(1, 20),
        FlSpot(2, 15),
        FlSpot(3, 30),
        FlSpot(4, 25),
      ];

      predictTrends();
    });
  }

  void predictTrends() {
    predictedUserTrend = predictNextTrend(userTrend);
    predictedRentalTrend = predictNextTrend(rentalTrend);
    predictedMembershipTrend = predictNextTrend(membershipTrend);
    predictedBookingTrends = predictNextTrend(bookingTrends);

    generateRecommendations();
  }

  List<FlSpot> predictNextTrend(List<FlSpot> trend) {
    if (trend.length < 2) return trend; // Not enough data to predict

    List<double> x = trend.map((e) => e.x).toList();
    List<double> y = trend.map((e) => e.y).toList();

    double meanX = x.reduce((a, b) => a + b) / x.length;
    double meanY = y.reduce((a, b) => a + b) / y.length;

    double ssX = x.fold(0, (prev, element) => prev + pow(element - meanX, 2));
    double ssY = y.fold(0, (prev, element) => prev + pow(element - meanY, 2));

    double ssXY = 0;
    for (int i = 0; i < x.length; i++) {
      ssXY += (x[i] - meanX) * (y[i] - meanY);
    }

    double slope = ssXY / ssX;
    double intercept = meanY - slope * meanX;

    double nextX = x.last + 1;
    double nextY = slope * nextX + intercept;

    return [...trend, FlSpot(nextX, nextY)];
  }

  void generateRecommendations() {
    recommendations.clear();
    print("Generating recommendations...");
    print("User Trend: ${predictedUserTrend.map((e) => e.y)}");
    print("Rental Trend: ${predictedRentalTrend.map((e) => e.y)}");
    print("Membership Trend: ${predictedMembershipTrend.map((e) => e.y)}");
    print("Booking Trend: ${predictedBookingTrends.map((e) => e.y)}");

    double userGrowth = predictedUserTrend.last.y - predictedUserTrend.first.y;
    double rentalGrowth =
        predictedRentalTrend.last.y - predictedRentalTrend.first.y;
    double membershipGrowth =
        predictedMembershipTrend.last.y - predictedMembershipTrend.first.y;
    double bookingGrowth =
        predictedBookingTrends.last.y - predictedBookingTrends.first.y;

    print("User Growth: $userGrowth");
    print("Rental Growth: $rentalGrowth");
    print("Membership Growth: $membershipGrowth");
    print("Booking Growth: $bookingGrowth");

    // Example logic for recommendations based on trend predictions
    if (userGrowth < 10) {
      recommendations
          .add("Consider increasing marketing efforts to attract more users.");
    }
    if (rentalGrowth < predictedUserTrend.last.y * 0.5) {
      recommendations
          .add("Optimize rental process to increase rental conversions.");
    }
    if (membershipGrowth < predictedUserTrend.last.y * 0.2) {
      recommendations.add("Promote membership benefits to increase sign-ups.");
    }
    if (bookingGrowth < predictedUserTrend.last.y * 0.3) {
      recommendations.add(
          "Improve booking system and offer discounts to increase bookings.");
    }
    print('Generated Recommendations: $recommendations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (totalUsers > totalRentals
                                ? totalUsers
                                : totalRentals)
                            .toDouble(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label;
                              switch (group.x.toInt()) {
                                case 0:
                                  label = 'Users';
                                  break;
                                case 1:
                                  label = 'Rentals';
                                  break;
                                case 2:
                                  label = 'Memberships';
                                  break;
                                default:
                                  label = '';
                                  break;
                              }
                              return BarTooltipItem(
                                '$label\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: rod.toY.toString(),
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const style = TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                );
                                Widget text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = const Text('Users', style: style);
                                    break;
                                  case 1:
                                    text = const Text('Rentals', style: style);
                                    break;
                                  case 2:
                                    text =
                                        const Text('Memberships', style: style);
                                    break;
                                  default:
                                    text = const Text('', style: style);
                                    break;
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: text,
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ));
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: totalUsers.toDouble(),
                                color: Colors.blue,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: totalRentals.toDouble(),
                                color: Colors.green,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: totalMemberships.toDouble(),
                                color: Colors.orange,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalUsers.toDouble(),
                            color: Colors.blue,
                            title: 'Users',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          PieChartSectionData(
                            value: totalRentals.toDouble(),
                            color: Colors.green,
                            title: 'Rentals',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          PieChartSectionData(
                            value: totalMemberships.toDouble(),
                            color: Colors.orange,
                            title: 'Memberships',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        centerSpaceColor: Colors.transparent,
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
             /* AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: userTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blue,
                          ),
                          LineChartBarData(
                            spots: rentalTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.green,
                          ),
                          LineChartBarData(
                            spots: membershipTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.orange,
                          ),
                          LineChartBarData(
                            spots: predictedUserTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blueAccent,
                            dashArray: [5, 5],
                          ),
                          LineChartBarData(
                            spots: predictedRentalTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.greenAccent,
                            dashArray: [5, 5],
                          ),
                          LineChartBarData(
                            spots: predictedMembershipTrend,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.orangeAccent,
                            dashArray: [5, 5],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),*/
              /* AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    'Booking Trends',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: bookingTrends,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blue,
                          ),
                          LineChartBarData(
                            spots: predictedBookingTrends,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blueAccent,
                            dashArray: [5, 5],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    'Predicted Trends',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: predictedUserTrend,
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blueAccent,
                            dashArray: [5, 5],
                          ),
                          LineChartBarData(
                            spots: predictedRentalTrend,
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.greenAccent,
                            dashArray: [5, 5],
                          ),
                          LineChartBarData(
                            spots: predictedMembershipTrend,
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.orangeAccent,
                            dashArray: [5, 5],
                          ),
                          LineChartBarData(
                            spots: predictedBookingTrends,
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.blueAccent,
                            dashArray: [5, 5],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    'Feedback Results',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),*/
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 5,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label;
                              switch (group.x.toInt()) {
                                case 0:
                                  label = 'Experience';
                                  break;
                                case 1:
                                  label = 'Price';
                                  break;
                                case 2:
                                  label = 'Condition';
                                  break;
                                case 3:
                                  label = 'App';
                                  break;
                                default:
                                  label = '';
                                  break;
                              }
                              return BarTooltipItem(
                                '$label\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: rod.toY.toString(),
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const style = TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                );
                                Widget text;
                                switch (value.toInt()) {
                                  case 0:
                                    text =
                                        const Text('Experience', style: style);
                                    break;
                                  case 1:
                                    text = const Text('Price', style: style);
                                    break;
                                  case 2:
                                    text =
                                        const Text('Condition', style: style);
                                    break;
                                  case 3:
                                    text = const Text('App', style: style);
                                    break;
                                  default:
                                    text = const Text('', style: style);
                                    break;
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: text,
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ));
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: averageExperienceRating,
                                color: Colors.blue,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: averagePriceRating,
                                color: Colors.green,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: averageConditionRating,
                                color: Colors.orange,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: averageAppRating,
                                color: Colors.purple,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: FadeTransition(
                  opacity: _animation,
                  /*child: const Text(
                    'Recommendations',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),*/
                ),
              ),
              ...recommendations.map((rec) {
                return AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        rec,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
