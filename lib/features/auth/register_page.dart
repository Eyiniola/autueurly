import 'package:auteurly/core/services/auth_service.dart';
import 'package:auteurly/features/components/squaretile.dart';
import 'package:auteurly/features/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/warning_pill.dart';
import 'package:auteurly/features/profile/create_profile/create_profile.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController =
      TextEditingController(); // Assuming this is 'fullName'
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // --- ADD STATE FOR ERROR MESSAGE ---
  String? _errorMessage;

  // --- HELPER TO SHOW ERROR ---
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // --- HELPER TO DISMISS ERROR ---
  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
  }
  // --- END OF ADDITIONS ---

  // sign up method email & password
  void _signUpWithEmailAndPassword() async {
    // --- Clear previous error ---
    _dismissError();

    // --- Basic validation ---
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    if (passwordController.text != confirmpasswordController.text) {
      // --- Use new error pill ---
      _showError("Passwords do not match.");
      return;
    }
    if (passwordController.text.length < 6) {
      _showError("Password must be at least 6 characters long.");
      return;
    }
    // --- End basic validation ---

    // Show loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUpWithEmail(
        fullName: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(), // Trim password too
      );
      // Check if signup was successful and the widget is still mounted
      if (user != null && mounted) {
        // Navigate to the Create Profile Page
        // Use pushReplacement to prevent going back to register
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CreateProfilePage(), // <-- Navigate here
          ),
        );
        // No need to set _isLoading = false here if navigating away
        return; // Exit function after navigation
      }
      // AuthWrapper will handle navigation on success
    } on FirebaseAuthException catch (e) {
      // --- Use new error pill with specific messages ---
      String message = "An error occurred during sign up.";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      _showError(message);
    } catch (e) {
      _showError("An unexpected error occurred: ${e.toString()}");
    } finally {
      // Hide loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // sign in method google (No error handling needed here as login page handles it)
  void _signInWithGoogle() async {
    try {
      _dismissError(); // Clear previous errors
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError("Google Sign-In failed. Please try again.");
    }
  }

  // --- REMOVED _showErrorSnackBar ---

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose(); // Dispose this one too
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1B1B),
      body: SafeArea(
        child: Center(
          // --- WRAP WITH SingleChildScrollView ---
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ), // Add overall padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30), // Adjusted top space
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
                const SizedBox(height: 30), // Adjusted spacing
                // --- ADD WARNING PILL ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: WarningPill(
                      message: _errorMessage!,
                      onDismissed: _dismissError,
                    ),
                  ),
                // --- END ADDITION ---

                //username textfield (Assuming this is Full Name)
                MyTextfield(
                  controller: usernameController,
                  hintText: 'Full Name', // Changed hint
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
                  hintText: 'Password (min. 6 characters)', // Added hint
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

                // Register Button
                ElevatedButton(
                  // Disable button while loading
                  onPressed: _isLoading ? null : _signUpWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA32626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Make button wider
                    padding: const EdgeInsets.symmetric(
                      vertical: 15, // Adjust vertical padding
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Show different style when disabled
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  // Show loading indicator or text
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign Up'), // Changed text
                ),

                const SizedBox(height: 30),

                Padding(
                  // Add padding around the divider row
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[600], thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[600], thickness: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Adjusted spacing
                // google sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: SquareTile(imagePath: 'lib/images/google.png'),
                    ),
                    const SizedBox(width: 25),
                    SquareTile(imagePath: 'lib/images/apple.png'),
                  ],
                ),
                const SizedBox(height: 30), // Adjusted spacing
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to login page
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
                const SizedBox(height: 50), // Bottom space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
