import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/glassy_text_field.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final AuthController _authController = AuthController();

  String? errorMessage;
  bool isLoading = false;

  // Handle Sign-Up
  void handleSignup() async {
    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final phoneNumber = phoneNumberController.text.trim();

    // Validate inputs
    if (username.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields.';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
      setState(() {
        errorMessage = 'Username can only contain letters and numbers.';
      });
      return;
    }

    if (!RegExp(r'^\d{11}$').hasMatch(phoneNumber)) {
      setState(() {
        errorMessage = 'Phone number must be exactly 11 digits.';
      });
      return;
    }


    // Show loading indicator
    setState(() {
      isLoading = true;
      errorMessage = null; // Clear error message
    });

    try {
      // Perform sign-up using AuthController
      await _authController.signup(
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      // Navigate to login screen on success
      Navigator.pop(context);
    } catch (e) {
      // Display error message
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade600, Colors.black],
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
                      size: 80,
                    ),
                    const SizedBox(height: 16),

                    // App Title
                    Text(
                      'Create Account',
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

                    // Username Input
                    GlassyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    // Phone Input
                    GlassyTextField(
                      controller: phoneNumberController,
                      hintText: 'Phone',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    GlassyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    GlassyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 10,
                        backgroundColor: Colors.deepOrange.shade700,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back to Login
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Login',
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
