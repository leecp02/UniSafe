import '../services/account_profile_service.dart';

class AccountProfileController {
  final AccountProfileService _service = AccountProfileService();

  AccountProfileService get service => _service;

  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String contactNumber,
    required String faculty,
    required String programme,
    required String gender,
  }) async {
    if (fullName.trim().isEmpty) {
      throw Exception('Full name is required.');
    }
    if (username.trim().isEmpty) {
      throw Exception('Username is required.');
    }
    if (contactNumber.trim().isEmpty) {
      throw Exception('Contact number is required.');
    }

    await _service.updateProfile(
      fullName: fullName.trim(),
      username: username.trim(),
      contactNumber: contactNumber.trim(),
      faculty: faculty.trim(),
      programme: programme.trim(),
      gender: gender.trim(),
    );
  }

  Future<void> deleteAccount() async {
    await _service.deleteCurrentAccount();
  }
}
