/*import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_done.dart';
import '../style/style.dart';
import '../widgets/steps_bar.dart';

class RegisterStep3 extends StatefulWidget {

  const RegisterStep3({super.key, required this.email, required this.password, required this.fullName, required this.matric, required this.faculty, required this.programme});

  final String email;
  final String password;
  final String fullName;
  final String matric;
  final String faculty;
  final String programme;

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {

  final usernameController = TextEditingController();
  final contactController = TextEditingController();

  String? gender;
  String? role;

  final AuthController controller = AuthController();
  bool isLoading = false;

  void registerUser() async {

    if(usernameController.text.isEmpty ||
        contactController.text.isEmpty ||
        gender == null){

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields"))
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print("Starting registration...");
      await controller.registerUser(
        widget.email,
        widget.password,
        widget.fullName,
        widget.matric,
        widget.faculty,
        widget.programme,
        usernameController.text,
        contactController.text,
        gender!,
        role!,
      );

      print("Registration successful, navigating...");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterDone()),
        );
      }
    } catch (e) {
      print("Registration error: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed: ${e.toString()}"))
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 100),
              color: CustomStyle.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("One last step...,", style: CustomStyle.lightH2),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.fromLTRB(40, 50, 40, 100),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const StepsBar(index: 1, len: 3),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(labelText: "Username"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: contactController,
                          decoration: const InputDecoration(labelText: "Contact Number"),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          hint: const Text("Select Gender"),
                          initialValue: gender,
                          items: ["Male", "Female"]
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val){
                            setState(() {
                              gender = val;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : registerUser,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_done.dart';
import '../style/style.dart';
import '../widgets/steps_bar.dart';

class RegisterStep3 extends StatefulWidget {
  const RegisterStep3({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
    required this.matric,
    required this.faculty,
    required this.programme,
    required this.role,
  });

  final String email;
  final String password;
  final String fullName;
  final String matric;
  final String faculty;
  final String programme;
  final String role;

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final usernameController = TextEditingController();
  final contactController = TextEditingController();

  String? gender;

  bool isLoading = false;

  Future<void> registerUser() async {
    if (usernameController.text.isEmpty ||
        contactController.text.isEmpty ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print("Starting registration...");

      // Call static method directly
      await AuthController.registerUser(
        email: widget.email,
        password: widget.password,
        fullName: widget.fullName,
        matric: widget.matric,
        faculty: widget.faculty,
        programme: widget.programme,
        username: usernameController.text,
        contactNumber: contactController.text,
        gender: gender!,
        role: widget.role,
      );

      print("Registration successful, navigating...");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterDone()),
        );
      }
    } catch (e) {
      print("Registration error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 100),
              color: CustomStyle.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("One last step...,", style: CustomStyle.lightH2),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.fromLTRB(40, 50, 40, 100),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const StepsBar(index: 1, len: 3),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          decoration:
                              const InputDecoration(labelText: "Username"),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: contactController,
                          decoration:
                              const InputDecoration(labelText: "Contact Number"),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          hint: const Text("Select Gender"),
                          value: gender,
                          items: ["Male", "Female"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => gender = val),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : registerUser,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text("Register"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}