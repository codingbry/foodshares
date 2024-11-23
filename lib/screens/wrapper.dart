import 'package:foodshares/screens/authenticate/authenticate.dart';
import 'package:foodshares/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Show a loading spinner while waiting for the user stream
    if (user == null) {
      return const Authenticate();  // If no user, show the authentication screen
    } else {
      return const Home();  // If user exists, show home screen
    }
  }
}