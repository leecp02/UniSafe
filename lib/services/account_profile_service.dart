import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AccountProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> watchCurrentProfile() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        return Stream<UserModel?>.value(null);
      }

      return _firestore.collection('users').doc(firebaseUser.uid).snapshots().map((doc) {
        if (!doc.exists) {
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

        return UserModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
      });
    });
  }

  Future<UserModel> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please sign in first.');
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

    return UserModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }

  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String contactNumber,
    required String faculty,
    required String programme,
    required String gender,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please sign in first.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName,
      'username': username,
      'contactNumber': contactNumber,
      'faculty': faculty,
      'programme': programme,
      'gender': gender,
    });
  }

  Future<void> deleteCurrentAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed in account.');
    }

    final userDocRef = _firestore.collection('users').doc(user.uid);
    final backupSnapshot = await userDocRef.get();
    final backupData = backupSnapshot.data();

    await userDocRef.delete();

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (backupData != null) {
        await userDocRef.set(backupData);
      }

      if (e.code == 'requires-recent-login') {
        throw Exception('Please log out and log in again before deleting your account.');
      }

      throw Exception(e.message ?? 'Failed to delete account.');
    }
  }
}
