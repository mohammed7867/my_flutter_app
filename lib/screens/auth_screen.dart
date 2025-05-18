import 'package:flutter/material.dart';
import '../widgets/auth_form.dart'; // your login/signup form widget

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'), // ✅ Your login bg
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Form on top of background
          Center(
            child: SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: AuthForm(), // ✅ Your existing login form
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
