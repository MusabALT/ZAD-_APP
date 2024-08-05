import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackSubmissionScreen extends StatefulWidget {
  const FeedbackSubmissionScreen({super.key});

  @override
  _FeedbackSubmissionScreenState createState() =>
      _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState extends State<FeedbackSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _hasSubmittedFeedback = false;

  double _experienceRating = 3.0;
  double _priceRating = 3.0;
  double _conditionRating = 3.0;
  double _appRating = 3.0;

  @override
  void initState() {
    super.initState();
    _checkIfFeedbackSubmitted();
  }

  Future<void> _checkIfFeedbackSubmitted() async {
    if (_currentUser != null) {
      final feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .doc(_currentUser.uid)
          .get();

      if (feedbackSnapshot.exists) {
        setState(() {
          _hasSubmittedFeedback = true;
        });
      }
    }
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('feedback')
            .doc(_currentUser!.uid)
            .set({
          'userId': _currentUser.uid,
          'experienceRating': _experienceRating,
          'priceRating': _priceRating,
          'conditionRating': _conditionRating,
          'appRating': _appRating,
          'timestamp': Timestamp.now(),
        });

        setState(() {
          _hasSubmittedFeedback = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    }
  }

  Widget _buildRatingBar(
      String label, double rating, Function(double) onRatingUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 8.0),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRatingUpdate,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text(
          'Submit Feedback',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _hasSubmittedFeedback
              ? const Center(
                  child: Text(
                    'Your feedback has been submitted, thank you!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildRatingBar(
                            'Rate Your Experience', _experienceRating,
                            (rating) {
                          setState(() {
                            _experienceRating = rating;
                          });
                        }),
                      ),
                      Expanded(
                        child: _buildRatingBar('Rate the Price', _priceRating,
                            (rating) {
                          setState(() {
                            _priceRating = rating;
                          });
                        }),
                      ),
                      Expanded(
                        child: _buildRatingBar(
                            'Rate the Car Condition', _conditionRating,
                            (rating) {
                          setState(() {
                            _conditionRating = rating;
                          });
                        }),
                      ),
                      Expanded(
                        child: _buildRatingBar(
                            'Rate the App Experience', _appRating, (rating) {
                          setState(() {
                            _appRating = rating;
                          });
                        }),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _submitFeedback,
                        child: const Text('Submit Feedback'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
