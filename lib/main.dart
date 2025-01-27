import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hedieaty/routes.dart';
import 'firebase_options.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  // String? token = await FirebaseMessaging.instance.getToken();
  // print("FCM Token: $token");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received: ${message.notification?.body}');
    // Handle the notification
    Fluttertoast.showToast(
      msg: "${message.notification?.body ?? "No Body"}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.teal.shade900,
      textColor: Colors.white,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked!');
    // Navigator.pushNamed(context, '/gift-details', arguments: message.data['giftId']);
  });


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Portrait mode
  ]);

  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
