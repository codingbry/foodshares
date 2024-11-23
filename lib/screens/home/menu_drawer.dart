import 'package:flutter/material.dart';
import 'package:foodshares/services/auth.dart';
import 'package:foodshares/screens/request/request_list.dart'; // Import your RequestList page

class MenuDrawer extends StatelessWidget {
  MenuDrawer({super.key});
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.green[400],
          ),
          child: const Text(
            'FoodShare',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          title: const Text('Requests List'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestList()),
            );
          },
        ),
        // Example of other items
        // ListTile(
        //   title: const Text('Item 2'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        ListTile(
          title: const Text('Logout'),
          onTap: () {
            _auth.signOut();
            Navigator.pop(context); // Close the drawer after logout
          },
        ),
      ],
    );
  }
}
