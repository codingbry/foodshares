import 'package:foodshares/screens/home/bottom_nav.dart';
import 'package:foodshares/screens/home/menu_drawer.dart';
import 'package:foodshares/screens/home/food_list.dart'; 
import 'package:foodshares/screens/home/add_list.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget currentScreen = const FoodList(); // Default screen

  void switchScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.green[50],
      endDrawer: Drawer(
        child: MenuDrawer(),
      ),
      body: currentScreen, // Display the current screen
      bottomNavigationBar: BottomNav(
        openDrawerCallback: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        onHomePressed: () => switchScreen(const FoodList()), // Switch to FoodList
        onAddPressed: () => switchScreen(const AddList()), // Switch to FoodList
      ),
    );
  }
}
