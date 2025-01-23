import 'package:flashcard/pages/signin.dart';
import 'package:flashcard/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool validateFields() {
    bool isValid = true;

    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      if (emailController.text.isEmpty) {
        emailError = "Email is required";
        isValid = false;
      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(emailController.text)) {
        emailError = "Enter a valid email";
        isValid = false;
      }

      if (passwordController.text.isEmpty) {
        passwordError = "Password is required";
        isValid = false;
      } else if (passwordController.text.length < 6) {
        passwordError = "Password must be at least 6 characters";
        isValid = false;
      }

      if (confirmPasswordController.text.isEmpty) {
        confirmPasswordError = "Confirm your password";
        isValid = false;
      } else if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError = "Passwords do not match";
        isValid = false;
      }
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E239D),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Email",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: Color(0xFF5E239D)),
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Password",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Color(0xFF5E239D)),
                  errorText: passwordError,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Confirm Password",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Re-enter your password",
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Color(0xFF5E239D)),
                  errorText: confirmPasswordError,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E239D),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (validateFields()) {
                      await AuthService().signup(
                        email: emailController.text,
                        password: passwordController.text,
                        context: context,
                      );
                    }
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignIn(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E239D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
