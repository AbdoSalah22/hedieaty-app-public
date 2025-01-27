import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/glassy_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  bool isLoading = false;

  // Error message to display to the user
  String? errorMessage;

  // Function to handle login
  void handleLogin() async {
    // Close the keyboard
    FocusScope.of(context).unfocus();

    // Validate fields
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please fill in both email and password.';
      });
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
      errorMessage = null; // Clear error message if any
    });

    try {
      // Perform login
      await _authController.login(
        context,
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      // Handle login errors (e.g., invalid credentials)
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Festive Icon
                    Icon(
                      Icons.card_giftcard,
                      color: Colors.amber.shade400,
                      size: 90,
                    ),
                    const SizedBox(height: 16),

                    // App Title
                    Text(
                      'Hedieaty',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Error Message
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Email Input
                    GlassyTextField(
                      key: const ValueKey('email_field'),
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    GlassyTextField(
                      key: const ValueKey('password_field'),
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      key: const ValueKey('login_button'),
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 10,
                        backgroundColor: Colors.teal.shade400,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Up Button
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
