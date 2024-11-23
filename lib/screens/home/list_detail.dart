import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class ListDetail extends StatelessWidget {
  final Map<String, dynamic> food;

  const ListDetail({super.key, required this.food});
  Future<void> sendRequest(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Check if user already requested this food using the listing UID (not food_id)
      final existingRequest = await FirebaseFirestore.instance
          .collection('requests')
          .where('user_id', isEqualTo: user.uid)
          .where('listId', isEqualTo: food['listId']) // Use food['listId']
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('You have already requested this food.');
      }

      // Check if there is enough quantity
      if (food['quantity'] <= 0) {
        throw Exception('This food is no longer available.');
      }

      // Check expiration date
      final expirationDate = (food['expiration_date'] as Timestamp?)?.toDate();
      if (expirationDate != null && expirationDate.isBefore(DateTime.now())) {
        throw Exception('This food item has expired.');
      }

      // Generate request ID
      final requestId =
          FirebaseFirestore.instance.collection('requests').doc().id;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Request data
      final requestData = {
        'request_id': requestId,
        'listId': food['listId'], // Store the UID of the listing in the request
        'food_name': food['food_name'],
        'user_id': user.uid,
        'request_date': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'fullName': userSnapshot['fullName'],
      };

      // Add the request to Firestore
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .set(requestData);

      // Update the food quantity in the listings collection
      // Uncomment if you want to decrement quantity after request
      // await FirebaseFirestore.instance
      //     .collection('listings') // Assuming your food collection is named 'listings'
      //     .doc(food['listId']) // Use food['listId'] for the document reference
      //     .update({'quantity': FieldValue.increment(-1)});

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thank you!'),
              content: const Text('Food allocation request sent successfully!'),
              actions: [
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
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Oops! Sorry'),
              content: Text('$e'),
              actions: [
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
    }
  }

  void requestFoodAllocation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Food Allocation'),
          content: Text(
            'You are requesting food allocation for "${food['food_name']}". Proceed with the request?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Request'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                sendRequest(context); // Send the request to Firebase
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format expiration date for display
    final expirationDate = (food['expiration_date'] as Timestamp?)?.toDate();
    final formattedExpirationDate = expirationDate != null
        ? DateFormat('MMM dd, yyyy').format(expirationDate)
        : 'No expiration date';

    return Scaffold(
      appBar: AppBar(
        title: Text(food['food_name'] ?? 'Food Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['food_name'] ?? 'No name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        food['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.inventory, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${food['quantity']} available',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Expires on: $formattedExpirationDate',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  requestFoodAllocation(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Request Food Allocation',
                    style: TextStyle(
                      fontSize: 16,
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
