class User {

  final String uid;
  
  User({ required this.uid });

}

class UserData {

  final String uid;
  final String fullName;
  final String address;
  final String phoneNumber;
  final double familyIncome;
  final String maritalStatus;
  final String userType;
  final int age;
  final int famMembers;

  UserData({
    required this.uid, 
    required this.fullName, 
    required this.address, 
    required this.phoneNumber, 
    required this.familyIncome, 
    required this.maritalStatus, 
    required this.userType, 
    required this.age, 
    required this.famMembers
  });

}