import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';
import '../models/user_model.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      print("Service: Creating user account...");
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);

      print("Service: User account created successfully");
      return result.user;
    } catch (e) {
      print("Service: Register error - ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      print("Service: Saving user data for UID: ${user.uid}");
      await _firestore
          .collection("users")
          .doc(user.uid)
          .set(user.toMap());
      print("Service: User data saved to Firestore successfully");
    } catch (e) {
      print("Service: Save user error - ${e.toString()}");
      throw Exception("Failed to save user: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<UserModel?> watchCurrentUserProfile() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        return Stream<UserModel?>.value(null);
      }

      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            fullName: '',
            matricNumber: '',
            faculty: '',
            programme: '',
            username: '',
            contactNumber: '',
            gender: '',
            role: 'student',
          );
        }

        return UserModel.fromMap(
          snapshot.id,
          snapshot.data() ?? <String, dynamic>{},
        );
      });
    });
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        fullName: '',
        matricNumber: '',
        faculty: '',
        programme: '',
        username: '',
        contactNumber: '',
        gender: '',
        role: 'student',
      );
    }

    return UserModel.fromMap(
      doc.id,
      doc.data() ?? <String, dynamic>{},
    );
  }

  Future<bool> isCurrentUserCounsellor() async {
    final profile = await getCurrentUserProfile();
    return profile?.isCounsellor ?? false;
  }
}