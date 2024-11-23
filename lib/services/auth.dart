import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map((user) {
      return user;
    });
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result =  await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Future<void> saveAdditionalDetails(String uid, String fullName, String address, String phoneNumber) async {
  Future<void> saveAdditionalDetails(String uid, String fullName, String address, String phoneNumber, 
    double familyIncome, String maritalStatus, String userType, int age, int famMembers) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullName,
        'address': address,
        'phoneNumber': phoneNumber,
        'familyIncome': familyIncome,
        'maritalStatus': maritalStatus,
        'userType': userType,
        'age': age,
        'famMembers': famMembers,
      });
    } catch (e) {
      print("Error saving additional details: $e");
    }
  }

  // Sign out function
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Add user data to Firestore
  Future<void> createUserDocument(User user, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'role': role,  // 'Donor', 'Recipient', or 'Charitable Organization'
      'verified': false,  // Initial verification status
    });
  }

}