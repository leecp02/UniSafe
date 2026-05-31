/*import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController {

  final AuthService _authService = AuthService();

  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> registerUser(
      String email,
      String password,
      String fullName,
      String matric,
      String faculty,
      String programme,
      String username,
      String contact,
      String gender,
      String role
      ) async {

    try {
      print("Controller: Starting registration for $email");
      User? user = await _authService.register(email, password);

      if (user != null) {
        print("Controller: User created with UID: ${user.uid}");

        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          matricNumber: matric,
          faculty: faculty,
          programme: programme,
          username: username,
          contactNumber: contact,
          gender: gender,
          role: role,
        );

        print("Controller: Saving user data to Firestore...");
        await _authService.saveUser(newUser);
        print("Controller: User data saved successfully");
      } else {
        print("Controller: User is null after registration");
        throw Exception("Failed to create user account");
      }
    } catch (e) {
      print("Controller: Error during registration: ${e.toString()}");
      rethrow;
    }
  }
}
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validates student email format (must be XXXXX@siswa.unimas.my)
  static bool _isValidStudentEmail(String email) {
    final studentEmailRegex = RegExp(r'^\d{5}@siswa\.unimas\.my$');
    return studentEmailRegex.hasMatch(email);
  }

  /// Registers a new user with email & password, and saves extra info to Firestore
  static Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String matric,
    required String faculty,
    required String programme,
    required String username,
    required String contactNumber,
    required String gender,
    required String role,
  }) async {
    try {
      // Validate student email format
      if (role.toLowerCase() == 'student') {
        if (!_isValidStudentEmail(email)) {
          throw Exception('Student email must follow format: 12345@siswa.unimas.my');
        }
      }

      // 1️⃣ Create Firebase Auth account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User registration failed");
      }

      // 2️⃣ Save extra details to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'matric': matric,
        'faculty': faculty,
        'programme': programme,
        'username': username,
        'contactNumber': contactNumber,
        'gender': gender,
        'role': role,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = e.message ?? "Registration failed";
      throw Exception(errorMessage);
    } catch (e) {
      // Handle all other errors
      throw Exception("Registration error: $e");
    }
  }
}