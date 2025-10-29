import 'package:auteurly/core/services/auth_service.dart';
import 'package:auteurly/features/auth/register_page.dart';
import 'package:auteurly/features/components/squaretile.dart';
import 'package:auteurly/features/components/textfield.dart';
import 'package:auteurly/features/components/warning_pill.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // create an instance of AuthService
  final AuthService _authService = AuthService();
  String? _errorMessage;

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
  }

  // sign in method email & password
  void _signInWithEmailAndPassword() async {
    try {
      // Clear previous errors on new attempt
      _dismissError();
      await _authService.signInWithEmail(
        email: emailController.text.trim(), // Trim whitespace
        password: passwordController.text.trim(),
      );
      // Login successful, error remains null (or you could navigate away)
    } on FirebaseAuthException catch (e) {
      // Use specific Firebase Auth error messages
      String message = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credentials provided.';
      }
      // Show the specific error
      _showError(message);
    } catch (e) {
      // Catch any other generic errors
      _showError("An unexpected error occurred: ${e.toString()}");
    }
  }

  // sign in method google
  void _signInWithGoogle() async {
    try {
      _dismissError(); // Clear previous errors
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError("Google Sign-In failed. Please try again.");
    }
  }
  // Dispose controllers when not needed

  @override
  void dispose() {
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
          // --- WRAP WITH SingleChildScrollView TO PREVENT OVERFLOW ---
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ), // Add overall padding
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

                const SizedBox(height: 10),
                //Auteurly Slogan (Row seems fine)
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

                const SizedBox(height: 30), // Adjusted spacing
                // --- ADD THE WARNING PILL CONDITIONALLY ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20.0,
                    ), // Space below pill
                    child: WarningPill(
                      message: _errorMessage!,
                      onDismissed: _dismissError,
                    ),
                  ),
                // --- END OF ADDITION ---

                // Username textfield
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 15), // Adjusted spacing
                // Password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 15), // Adjusted spacing
                // forgot password link
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                  ), // Use overall padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[200], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Login Button
                ElevatedButton(
                  onPressed: _signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFA32626,
                    ), // Your app's color
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Make button wider
                    padding: const EdgeInsets.symmetric(
                      vertical: 15, // Adjust vertical padding
                    ),
                    shape: RoundedRectangleBorder(
                      // More rounded corners
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),

                const SizedBox(height: 40), // Adjusted spacing

                Padding(
                  // Add padding around the divider row
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[600], // Darker grey
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ), // Lighter grey
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[600], thickness: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // Adjusted spacing
                // google sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Removed SizedBox for better centering
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: SquareTile(imagePath: 'lib/images/google.png'),
                    ),
                    const SizedBox(width: 25), // Adjusted spacing
                    SquareTile(imagePath: 'lib/images/apple.png'),
                  ],
                ),
                const SizedBox(height: 40), // Adjusted spacing
                // sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              // Ensure RegisterPage exists and is imported
                              return RegisterPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Color(0xFFA32626),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50), // Bottom space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
