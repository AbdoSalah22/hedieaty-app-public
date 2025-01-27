import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication error');
    }
  }

  User? get currentUser => _auth.currentUser;
  String get currentUserUid => _auth.currentUser?.uid ?? '';
}
