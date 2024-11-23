import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestList extends StatelessWidget {
  const RequestList({super.key});

  Future<void> approveRequest(String requestId, String listId) async {
    final requestRef =
        FirebaseFirestore.instance.collection('requests').doc(requestId);
    final listingRef =
        FirebaseFirestore.instance.collection('listings').doc(listId);

    try {
      // Update the request status to Approved
      await requestRef.update({'status': 'Approved'});

      // Decrement the quantity of the listing
      await listingRef.update({'quantity': FieldValue.increment(-1)});

      debugPrint('Request $requestId approved successfully.');
    } catch (e) {
      debugPrint('Error approving request: $e');
      rethrow;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final requestRef =
        FirebaseFirestore.instance.collection('requests').doc(requestId);

    try {
      // Update the request status to Rejected
      await requestRef.update({'status': 'Rejected'});

      debugPrint('Request $requestId rejected successfully.');
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No pending requests found.'),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id; // Get the document ID
              final listId =
                  request['listId']; // Get the listId for the food item

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(request['food_name'] ?? 'Unnamed Item'),
                  subtitle: Text(
                    'Requested by: ${request['fullName'] ?? 'Unknown'}\n'
                    'Date: ${request['request_date'] != null ? (request['request_date'] as Timestamp).toDate().toString() : 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await approveRequest(requestId, listId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request approved.')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await rejectRequest(requestId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request rejected.')),
                          );
                        },
                      ),
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
