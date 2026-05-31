import 'package:flutter/material.dart';

import '../controllers/account_profile_controller.dart';
import '../models/user_model.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  final AccountProfileController controller = AccountProfileController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController programmeController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  static const List<String> facultyList = [
    'FCSIT',
    'FEB',
    'FENG',
    'FACA',
    'FCSHD',
    'FMHS',
    'FSSH',
    'FRST',
    'FLC',
    'FBE',
  ];

  static const List<String> genderList = ['Male', 'Female'];

  bool isSaving = false;
  bool isDeleting = false;
  String? selectedFaculty;
  String? selectedGender;

  void _showLockedFieldAlert(String fieldName, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$fieldName locked'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    contactController.dispose();
    facultyController.dispose();
    programmeController.dispose();
    genderController.dispose();
    super.dispose();
  }

  void _hydrate(UserModel profile) {
    if (fullNameController.text.isEmpty) {
      fullNameController.text = profile.fullName;
      usernameController.text = profile.username;
      contactController.text = profile.contactNumber;
      facultyController.text = profile.faculty;
      programmeController.text = profile.programme;
      genderController.text = profile.gender;
      selectedFaculty = profile.faculty.isEmpty ? null : profile.faculty;
      selectedGender = profile.gender.isEmpty ? null : profile.gender;
    }
  }

  Future<void> _save() async {
    if (isSaving || isDeleting) {
      return;
    }

    setState(() => isSaving = true);

    try {
      await controller.updateProfile(
        fullName: fullNameController.text,
        username: usernameController.text,
        contactNumber: contactController.text,
        faculty: selectedFaculty ?? facultyController.text,
        programme: programmeController.text,
        gender: selectedGender ?? genderController.text,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (isDeleting || isSaving) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This action is permanent and cannot be undone. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => isDeleting = true);

    try {
      await controller.deleteAccount();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
      ),
      body: StreamBuilder<UserModel?>(
        stream: controller.service.watchCurrentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(
              child: Text('Unable to load your profile. Please sign in again.'),
            );
          }

          _hydrate(profile);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                initialValue: profile.email,
                readOnly: true,
                onTap: () => _showLockedFieldAlert(
                  'Email',
                  'Email cannot be changed after registration.',
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: profile.role,
                readOnly: true,
                onTap: () => _showLockedFieldAlert(
                  'Role',
                  'Role cannot be changed after registration.',
                ),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: profile.matricNumber,
                readOnly: true,
                onTap: () => _showLockedFieldAlert(
                  'Matric Number',
                  'Matric number cannot be changed after registration.',
                ),
                decoration: const InputDecoration(
                  labelText: 'Matric Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedFaculty,
                decoration: const InputDecoration(
                  labelText: 'Faculty',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Faculty'),
                items: facultyList
                    .map(
                      (faculty) => DropdownMenuItem(
                        value: faculty,
                        child: Text(faculty),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFaculty = value;
                    facultyController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: programmeController,
                decoration: const InputDecoration(
                  labelText: 'Programme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Gender'),
                items: genderList
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                    genderController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: isDeleting ? null : _deleteAccount,
                child: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }
}
