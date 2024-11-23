import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodshares/services/add_listing.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

final User? user = FirebaseAuth.instance.currentUser;
final String userId = user?.uid ?? '';
String fullName = '';

class AddList extends StatefulWidget {
  const AddList({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  final _formKey = GlobalKey<FormState>();

  // Image-related variables
  File? _imageFile;
  final picker = ImagePicker();

  // Form data
  String foodName = '';
  String description = '';
  int quantity = 0;
  DateTime? expirationDate;
  String type = 'Donate';
  String listId = '';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      } else {
        debugPrint('No image selected.');
      }
    } catch (e) {
      debugPrint('Error while picking an image: $e');
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) return ''; // If no image, return empty string

    try {
      // Get the reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('food_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the image to Firebase Storage
      final uploadTask = storageRef.putFile(_imageFile!);
      await uploadTask;

      // Get the download URL
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _submitForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    fullName = userSnapshot['fullName'];

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Upload image to Firebase Storage if needed
      // final imageUrl = await _uploadImage();

      // Add the data to Firestore
      await addListing(
        foodName: foodName,
        description: description,
        quantity: quantity,
        expirationDate: expirationDate,
        id: listId,
        fullName: fullName,
      );

      debugPrint('Form submitted and data uploaded to Firestore!');
      // Clear the form
      _formKey.currentState?.reset();

      // Show a success pop-up message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thank you!'),
            content: const Text('Successfuly added to the listing!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Food',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Center align the title
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Center(child: Text('Tap to upload image')),
                ),
              ),
              const SizedBox(height: 16.0),

              // Food Name Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter food name' : null,
                onSaved: (value) => foodName = value!,
              ),
              const SizedBox(height: 16.0),

              // Description Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a description'
                    : null,
                onSaved: (value) => description = value!,
              ),
              const SizedBox(height: 16.0),

              // Quantity Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter quantity';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
                onSaved: (value) => quantity = int.parse(value!),
              ),
              const SizedBox(height: 16.0),

              // Expiration Date Picker
              Row(
                children: [
                  const Text('Exp. Date:'),
                  const SizedBox(width: 16.0),
                  Text(
                    expirationDate == null
                        ? 'YYYY/MM/DD'
                        : expirationDate.toString().split(' ')[0],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              // const SizedBox(height: 16.0),

              // // Type Dropdown
              // DropdownButtonFormField<String>(
              //   value: type,
              //   decoration: const InputDecoration(labelText: 'Type'),
              //   items: ['Request', 'Donate']
              //       .map((type) => DropdownMenuItem(
              //             value: type,
              //             child: Text(type),
              //           ))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       type = value!;
              //     });
              //   },
              // ),
              const SizedBox(height: 24.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expirationDate = picked;
      });
    }
  }
}
