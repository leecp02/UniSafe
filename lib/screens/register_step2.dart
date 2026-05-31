import 'package:flutter/material.dart';
import 'register_step3.dart';
import '../style/style.dart';
import '../widgets/steps_bar.dart';

class RegisterStep2 extends StatefulWidget {

  const RegisterStep2({super.key, required this.password, required this.email, required this.role});

  final String email;
  final String password;
  final String role;

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {

  final fullNameController = TextEditingController();
  final matricController = TextEditingController();
  final programmeController = TextEditingController();

  String? faculty;

  final facultyList = ["FCSIT", "FEB", "FENG", "FACA", "FCSHD", "FMHS", "FSSH", "FRST", "FLC", "FBE"];

  @override
  void dispose() {
    fullNameController.dispose();
    matricController.dispose();
    programmeController.dispose();
    super.dispose();
  }

  void nextStep() {

    if(fullNameController.text.isEmpty ||
        matricController.text.isEmpty ||
        faculty == null ||
        programmeController.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete all fields"))
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterStep3(
          email: widget.email,
          password: widget.password,
          role: widget.role,
          fullName: fullNameController.text,
          matric: matricController.text,
          faculty: faculty!,
          programme: programmeController.text,
        ),
      ),
    );
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
                  Text("Keep going...", style: CustomStyle.lightH2),
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
                          controller: fullNameController,
                          decoration: const InputDecoration(
                            label: Text("Full Name"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: matricController,
                          decoration: const InputDecoration(
                            label: Text("Matric Number"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          hint: const Text("Select Faculty"),
                          initialValue: faculty,
                          items: facultyList.map((e) =>
                              DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val){
                            setState(() {
                              faculty = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: programmeController,
                          decoration: const InputDecoration(
                            label: Text("Programme"),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: nextStep,
                            child: const Text("Next"),
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