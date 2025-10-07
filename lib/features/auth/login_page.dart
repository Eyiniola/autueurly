import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../components/textfield.dart';
//import '../components/button.dart';
import '../components/squaretile.dart';
import 'register_page.dart';

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

  // sign in method email & password
  void _signInWithEmailAndPassword() async {
    await _authService.signInWithEmail(
      email: emailController.text,
      password: passwordController.text,
    );
  }

  // sign in method google
  void _signInWithGoogle() async {
    await _authService.signInWithGoogle();
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
              // Username textfield
              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 20),
              // Password textfield
              MyTextfield(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // forgot password link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  backgroundColor: const Color(0xFFA32626), // Your app's color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 20,
                  ),
                ),
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 50),

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
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[200], fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
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
            ],
          ),
        ),
      ),
    );
  }
}
