import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addListing({
  required String foodName,
  required String description,
  required int quantity,
  required DateTime? expirationDate,
  required String id,
  required String fullName,
  // File? imageFile, // Optional
}) async {
  try {
    // Get the current user's UID
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // final imageUrl = await _uploadImage(imageFile); // Upload image to Firebase Storage and get URL

    // Generate list ID
    final listId = FirebaseFirestore.instance.collection('listings').doc().id;

    // Request data
    final listData = {
      'user_id': userId, // Linking the listing to the user's UID
      'fullName': fullName,
      'food_name': foodName,
      'description': description,
      'quantity': quantity,
      'expiration_date': expirationDate,
      'listId': listId,
      // 'image_url': imageUrl, // Optional: store image URL in Firestore
      'timestamp': FieldValue
          .serverTimestamp(), // Optional: timestamp for sorting/listing
    };

    // Add the request to Firestore
    await FirebaseFirestore.instance
        .collection('listings')
        .doc(listId)
        .set(listData);

    debugPrint('Listing added successfully');
  } catch (e) {
    debugPrint('Error adding listing: $e');
  }
}
