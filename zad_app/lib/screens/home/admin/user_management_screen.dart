import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> _selectedUsers = {};

  bool _isSelectionMode = false;

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUsers.clear();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      _selectedUsers[userId] = !_selectedUsers[userId]!;
    });
  }

  Future<void> _deleteSelectedUsers() async {
    for (String userId in _selectedUsers.keys) {
      if (_selectedUsers[userId]!) {
        var userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data()?['role'] != 'admin') {
          try {
            await _firestore.collection('users').doc(userId).delete();
          } catch (e) {
            _showAlert('Error deleting user: $e');
          }
        } else {
          _showAlert('Cannot delete admin user: ${userDoc.data()?['name']}');
        }
      }
    }
    _showAlert('Selected users deleted successfully');
    _toggleSelectionMode();
  }

  Future<void> _updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      _showAlert('User updated successfully');
    } catch (e) {
      _showAlert('Error updating user: $e');
    }
  }

  Future<void> _viewUserRentals(String userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRentalsScreen(userId: userId),
      ),
    );
  }

  void _showUpdateDialog(String userId, Map<String, dynamic> userData) {
    final TextEditingController emailController =
        TextEditingController(text: userData['email']);
    final TextEditingController nameController =
        TextEditingController(text: userData['name']);
    final TextEditingController phoneNumberController =
        TextEditingController(text: userData['phoneNumber']);
    final TextEditingController addressController =
        TextEditingController(text: userData['address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  'email': emailController.text,
                  'name': nameController.text,
                  'phoneNumber': phoneNumberController.text,
                  'address': addressController.text,
                };
                _updateUser(userId, updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notification'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showMembershipDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Membership'),
          content: const Text(
              'Are you sure you want to give this user a membership?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addMembership(userId);
                Navigator.of(context).pop();
              },
              child: const Text('Add Membership'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMembership(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hasMembership': true,
        'points': 0,
      });
      _showAlert('Membership added successfully');
    } catch (e) {
      _showAlert('Error adding membership: $e');
    }
  }

  void _showAddPointsDialog(String userId) {
    final TextEditingController pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Points'),
          content: TextField(
            controller: pointsController,
            decoration: const InputDecoration(labelText: 'Points'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int points = int.parse(pointsController.text);
                _addPoints(userId, points);
                Navigator.of(context).pop();
              },
              child: const Text('Add Points'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPoints(String userId, int points) async {
    try {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      int currentPoints = userDoc.data()?['points'] ?? 0;
      await _firestore.collection('users').doc(userId).update({
        'points': currentPoints + points,
      });
      _showAlert('Points added successfully');
    } catch (e) {
      _showAlert('Error adding points: $e');
    }
  }

  void _showAddNoteDialog(String userId) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNoteToUser(userId, noteController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNoteToUser(String userId, String note) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'note': note,
      });
      _showAlert('Note added successfully');
    } catch (e) {
      _showAlert('Error adding note: $e');
    }
  }

  Future<void> _deleteNoteFromUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'note': FieldValue.delete(),
      });
      _showAlert('Note deleted successfully');
    } catch (e) {
      _showAlert('Error deleting note: $e');
    }
  }

  void _showSendAlertDialog(String userId) {
    final TextEditingController alertController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Alert'),
          content: TextField(
            controller: alertController,
            decoration: const InputDecoration(labelText: 'Alert Message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _sendAlertToUser(userId, alertController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Send Alert'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendAlertToUser(String userId, String alertMessage) async {
    try {
      await _firestore.collection('alerts').add({
        'userId': userId,
        'message': alertMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _showAlert('Alert sent successfully');
    } catch (e) {
      _showAlert('Error sending alert: $e');
    }
  }

  Future<void> _togglePaymentStatus(String userId, bool paymentMade) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'paymentMade': paymentMade,
      });
      _showAlert('Payment status updated successfully');
    } catch (e) {
      _showAlert('Error updating payment status: $e');
    }
  }

  void _chatWithUser(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text(''),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog();
                  },
                ),
              ]
            : null,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _toggleSelectionMode();
                },
              )
            : null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          for (var user in users) {
            if (!_selectedUsers.containsKey(user.id)) {
              _selectedUsers[user.id] = false;
            }
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userData = user.data() as Map<String, dynamic>;

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedUsers[user.id] = true;
                  });
                },
                onTap: _isSelectionMode
                    ? () {
                        _toggleUserSelection(user.id);
                      }
                    : null,
                child: Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: _selectedUsers[user.id],
                            onChanged: (bool? value) {
                              _toggleUserSelection(user.id);
                            },
                          )
                        : const Icon(Icons.person),
                    title: Text('Name: ${userData['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${userData['email']}'),
                        Text('Phone: ${userData['phoneNumber']}'),
                        Text('Address: ${userData['address']}'),
                        Text(
                            'Membership: ${userData['hasMembership'] ?? false ? 'Yes' : 'No'}'),
                        Text('Points: ${userData['points'] ?? 0}'),
                        Text(
                            'Payment: ${userData['paymentMade'] == true ? 'Completed' : 'Pending'}'),
                        if (userData.containsKey('note'))
                          Row(
                            children: [
                              Expanded(
                                  child: Text('Note: ${userData['note']}')),
                              IconButton(
                                icon: const Icon(Icons.delete_forever),
                                onPressed: () {
                                  _deleteNoteFromUser(user.id);
                                },
                              ),
                            ],
                          ),
                        Wrap(
                          spacing: 4.0,
                          children: [
                            IconButton(
                              icon: Icon(
                                userData['paymentMade'] == true
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: userData['paymentMade'] == true
                                    ? Colors.green
                                    : Colors.yellow,
                              ),
                              onPressed: () {
                                bool newStatus =
                                    !(userData['paymentMade'] == true);
                                _togglePaymentStatus(user.id, newStatus);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.card_membership),
                              color: userData['hasMembership'] ?? false
                                  ? Colors.amber
                                  : Colors.grey,
                              onPressed: () {
                                _showMembershipDialog(user.id);
                              },
                            ),
                            /* IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _showAddPointsDialog(user.id);
                              },
                            ),*/
                            IconButton(
                              icon: const Icon(Icons.note_add),
                              onPressed: () {
                                _showAddNoteDialog(user.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.notification_add),
                              onPressed: () {
                                _showSendAlertDialog(user.id);
                              },
                            ),
                            /* IconButton(
                              icon: const Icon(Icons.chat),
                              onPressed: () {
                                _chatWithUser(user.id);
                              },
                            ),*/
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateDialog(user.id, userData);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                _viewUserRentals(user.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete the selected users?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              _deleteSelectedUsers();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class UserRentalsScreen extends StatelessWidget {
  final String userId;

  const UserRentalsScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 12, 190),
        title: const Text('User Rentals'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('rentals')
            .where('uid', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              var rental = rentals[index];
              var rentalData = rental.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.car_rental),
                  title: Text('Car: ${rentalData['carName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Price: \$${rentalData['totalPrice']}'),
                      Text('Rental Days: ${rentalData['rentalDays']}'),
                      Text('Payment Method: ${rentalData['paymentMethod']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String userId;

  const ChatScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your chat screen here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with User'),
      ),
      body: const Center(
        child: Text('Chat screen implementation goes here'),
      ),
    );
  }
}
