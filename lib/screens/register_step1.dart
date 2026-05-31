import 'package:flutter/material.dart';
import 'register_step2.dart';
import '../style/style.dart';
import '../widgets/steps_bar.dart';

class RegisterStep1 extends StatefulWidget {

  const RegisterStep1({super.key, });

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole = 'student';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmailFormat(String email, String? role) {
    if (email.isEmpty) return "Email cannot be empty";
    if (role == 'student') {
      final studentEmailRegex = RegExp(r'^\d{5}@siswa\.unimas\.my$');
      if (!studentEmailRegex.hasMatch(email)) {
        return "Student email must follow format: 12345@siswa.unimas.my";
      }
    }
    return null;
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
                  Text("Welcome,", style: CustomStyle.lightH2),
                  Text("Register Now!", style: CustomStyle.lightH2),
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
                        const SizedBox(height: 30),
                        const Text("Select Role"),
                        const SizedBox(height: 10),
                        DropdownButtonFormField(
                          hint: const Text("Select your role"),
                          initialValue: selectedRole,
                          items: ["student", "counsellor"]
                              .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e == "student" ? "Student" : "Counsellor"),
                              ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedRole = val;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            label: const Text("Email"),
                            helperText: selectedRole == "student" 
                              ? "Format: 12345@siswa.unimas.my" 
                              : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            label: Text("Password"),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            child: const Text("Next"),
                            onPressed: () {
                              final emailError = _validateEmailFormat(emailController.text, selectedRole);
                              if (emailError != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(emailError)),
                                );
                                return;
                              }
                              if (passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Password cannot be empty")),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterStep2(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    role: selectedRole ?? 'student',
                                  ),
                                ),
                              );
                            },
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