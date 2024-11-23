import 'package:flutter/material.dart';
import 'package:foodshares/services/auth.dart';
import 'package:foodshares/shared/constants.dart';
import 'package:foodshares/shared/loading.dart';

class RegisterTwo extends StatefulWidget {
  final String email;
  final String password;

  const RegisterTwo(this.email, this.password, {super.key});

  @override
  _RegisterTwoState createState() => _RegisterTwoState();
}

class _RegisterTwoState extends State<RegisterTwo> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // Fields for personal details
  String fullName = '';
  String address = '';
  String phoneNumber = '';
  double familyIncome = 0.0;
  String maritalStatus = 'Single';
  String userType = 'Donor';
  int age = 0;
  int famMembers = 0;


  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      backgroundColor: Colors.green[100],
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[400],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.food_bank,
                        size: 60.0,
                        color: Colors.white,
                      ),
                      Text(
                        'FoodShare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('1', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(child: Divider(color: Colors.green)),
                      SizedBox(width: 10.0),
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('2', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Enter your full name' : null,
                  onChanged: (val) => setState(() => fullName = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Address'),
                  validator: (val) => val!.isEmpty ? 'Enter your address' : null,
                  onChanged: (val) => setState(() => address = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Phone Number'),
                  validator: (val) => val!.isEmpty ? 'Enter your phone number' : null,
                  onChanged: (val) => setState(() => phoneNumber = val),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Family Income'),
                  validator: (val) => val!.isEmpty ? 'Enter your family income' : null,
                  onChanged: (val) => setState(() => familyIncome = double.tryParse(val) ?? 0.0),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: maritalStatus,
                        decoration: textInputDecoration.copyWith(hintText: 'Marital Status'),
                        items: <String>['Single', 'Married']
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            maritalStatus = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: userType,
                        decoration: textInputDecoration.copyWith(hintText: 'User Type'),
                        items: <String>['Donor', 'Recipient', 'BCO']
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            userType = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded( 
                      child: TextFormField(
                          decoration: textInputDecoration.copyWith(hintText: '# of Fam. members'),
                          validator: (val) => val!.isEmpty ? 'Enter the number of family members' : null,
                          onChanged: (val) => setState(() => famMembers = int.tryParse(val) ?? 0),
                        ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                          child: TextFormField(
                              decoration: textInputDecoration.copyWith(hintText: 'Age'),
                              validator: (val) => val!.isEmpty ? 'Enter your age' : null,
                              onChanged: (val) => setState(() => age = int.tryParse(val) ?? 0),
                            ),
                          ),
                      ],
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.green[400]!),
                  ),
                  onPressed: () async {
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      dynamic user = await _auth.register(widget.email, widget.password);
                      await _auth.saveAdditionalDetails(user.uid, fullName, address, phoneNumber, familyIncome, maritalStatus, userType, age, famMembers);
                      Navigator.pop(context);
                      if (user == null) {
                        setState(() {
                          error = 'Error registering user';
                          loading = false;
                        });
                      }
                    }
                  },
                  child: const Text(
                    'Complete Registration',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
