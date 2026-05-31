import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterDone extends StatelessWidget {

  const RegisterDone({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(Icons.check_circle,
                color: Colors.green,
                size: 100),

            const SizedBox(height: 20),

            const Text(
              "Successfully Registered!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              child: const Text("Done"),
              onPressed: (){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LoginPage()));
              },
            )
          ],
        ),
      ),
    );
  }
}