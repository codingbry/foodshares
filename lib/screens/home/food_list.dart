import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodshares/screens/home/list_detail.dart';

class FoodList extends StatelessWidget {
  const FoodList({super.key});

  // Function to fetch food listings from Firestore
  Stream<QuerySnapshot> getFoodListings() {
    return FirebaseFirestore.instance.collection('listings').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Center align the title
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getFoodListings(), // Listen to the Firestore data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return const Center(child: Text('No food listings available.'));
          }

          final foodItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              var food = foodItems[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.white,
                  ),
                ),
                title: Text(food['food_name'] ?? 'No name'),
                subtitle: Text(food['description'] ?? 'No description'),
                trailing: Text('${food['quantity']} available'),
                onTap: () {
                  // Navigate to detailed page and pass the food data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListDetail(food: food.data() as Map<String, dynamic>),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
