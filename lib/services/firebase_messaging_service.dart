import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }
}
