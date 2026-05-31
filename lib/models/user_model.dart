class UserModel {
  String uid;
  String email;
  String fullName;
  String matricNumber;
  String faculty;
  String programme;
  String username;
  String contactNumber;
  String gender;
  String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.matricNumber,
    required this.faculty,
    required this.programme,
    required this.username,
    required this.contactNumber,
    required this.gender, 
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'matricNumber': matricNumber,
      'faculty': faculty,
      'programme': programme,
      'username': username,
      'contactNumber': contactNumber,
      'gender': gender,
      'role': role,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: (map['email'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      matricNumber: (map['matricNumber'] ?? map['matric'] ?? '').toString(),
      faculty: (map['faculty'] ?? '').toString(),
      programme: (map['programme'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      role: (map['role'] ?? 'student').toString(),
    );
  }

  bool get isCounsellor => role.toLowerCase() == 'counsellor';
}