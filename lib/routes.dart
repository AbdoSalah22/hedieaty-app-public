import 'package:flutter/material.dart';
import 'package:hedieaty/views/login_page.dart';
import 'package:hedieaty/widgets/main_navigator.dart';
import 'package:hedieaty/views/signup_page.dart';
import 'package:hedieaty/widgets/splash_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    signup: (context) => SignupPage(),
    main: (context) => MainNavigator(),
  };
}
