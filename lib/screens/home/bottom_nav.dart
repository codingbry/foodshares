import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final VoidCallback openDrawerCallback;
  final VoidCallback onHomePressed; // Callback for Home button
  final VoidCallback onAddPressed; // Callback for Home button

  const BottomNav({super.key, required this.openDrawerCallback, required this.onHomePressed, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: BottomAppBar(
        color: Colors.green,
        child: Container(
          height: 50.0,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                color: const Color.fromARGB(255, 248, 215, 215),
                icon: const Icon(Icons.home),
                onPressed: onHomePressed, // Call the callback to switch to FoodList
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Colors.green,
                  icon: const Icon(Icons.add),
                  onPressed: onAddPressed
                ),
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.person),
                onPressed: openDrawerCallback, // Call the callback to open the drawer
              ),
            ],
          ),
        ),
      ),
    );
  }
}
