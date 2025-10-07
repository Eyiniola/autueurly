import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../components/textfield.dart';
//import '../components/button.dart';
import '../components/squaretile.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  // create an instance of AuthService
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // sign up method email & password
  void _signUpWithEmailAndPassword() async {
    print("======== LOGIN BUTTON TAPPED! ========");
    if (passwordController.text != confirmpasswordController.text) {
      _showErrorSnackBar("Passwords do not match.");
      return;
    }
    // Show loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmail(
        fullName: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      // The AuthWrapper will handle navigation on success
    } on FirebaseAuthException catch (e) {
      // Show an error message to the user
      _showErrorSnackBar(e.message ?? "An unknown error occurred.");
    } finally {
      // Hide loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // sign in method google
  void _signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Dispose controllers when not needed

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1B1B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Auteurly Logo
              Image(
                image: AssetImage('lib/images/logo.png'),
                height: 100,
                width: 300,
              ),

              const SizedBox(height: 5),
              //Auteurly Slogan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Connect the',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    'Talent',
                    style: TextStyle(
                      color: Color(0xFFA32626),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    'Create the',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 5),

                  const Text(
                    'Vision',
                    style: TextStyle(
                      color: Color(0xFFA32626),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              //username textfield
              MyTextfield(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),
              // email textfield
              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),
              // Password textfield
              MyTextfield(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // confirm password textfield
              MyTextfield(
                controller: confirmpasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(height: 25),

              // Login Button
              ElevatedButton(
                onPressed: _signUpWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA32626), // Your app's color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 20,
                  ),
                ),
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[200],
                      thickness: 0.5,
                      indent: 40,
                      endIndent: 20,
                    ),
                  ),

                  Text(
                    'Or continue with',
                    style: TextStyle(color: Colors.grey[200], fontSize: 12),
                  ),

                  Expanded(
                    child: Divider(
                      color: Colors.grey[200],
                      thickness: 0.5,
                      indent: 20,
                      endIndent: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              // google sign in button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 50),
                  GestureDetector(
                    onTap: _signInWithGoogle,
                    child: SquareTile(imagePath: 'lib/images/google.png'),
                  ),
                  const SizedBox(width: 50),
                  SquareTile(imagePath: 'lib/images/apple.png'),
                ],
              ),
              const SizedBox(height: 50),
              // sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(color: Colors.grey[200], fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Color(0xFFA32626),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
