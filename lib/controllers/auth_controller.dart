import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/remote/remote_user_model.dart';
import '../routes.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/google_cloud_api.dart';


class AuthController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  /// Login using email and password using Firebase Authentication
  Future<void> login(BuildContext context, String email, String password) async {
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        final userData = await _firestoreService.getUser(user.uid);

        if (userData != null) {
          final token = await _messagingService.getFCMToken();
          if (token != null) {
            await _firestoreService.updateUserFCMToken(user.uid, token);
          }
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else {
          throw Exception('User data not found.');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// Sign up a user using Firebase Authentication and save their information in Firestore.
  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Check if the username is unique before creating the user
      final isUnique = await _firestoreService.isUsernameUnique(username);
      if (!isUnique) {
        throw Exception('This username is already taken.');
      }

      // Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      User? user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed. Please try again.');
      }

      // Create a new user
      RemoteUserModel newUser = RemoteUserModel(
        uid: user.uid,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestoreService.addUser(newUser);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already in use.');
        case 'weak-password':
          throw Exception('The password is too weak.');
        default:
          throw Exception('Signup failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
