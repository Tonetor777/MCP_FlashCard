import 'package:flashcard/services/auth_service.dart';
import 'package:flutter/material.dart';
import './signup.dart';
import './home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? signInError;

  bool validateFields() {
    bool isValid = true;

    setState(() {
      emailError = null;
      passwordError = null;

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
      }
    });

    return isValid;
  }

  Future<void> handleSignIn() async {
    if (validateFields()) {
      bool success = await AuthService().signin(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );

      if (!success) {
        setState(() {
          signInError = "Incorrect email or password";
        });
      } else {
        setState(() {
          signInError = null;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E239D),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Email or Username",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF5E239D)),
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
            if (signInError != null) // Display sign-in error if it exists
              Center(
                child: Text(
                  signInError!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E239D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: handleSignIn,
                child: const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("Don't have an account?"),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUp(),
                    ),
                  ); // Navigate to Sign Up page
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5E239D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
