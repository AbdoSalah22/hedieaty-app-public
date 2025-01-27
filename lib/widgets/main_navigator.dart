import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../views/login_page.dart';
import '../views/home_page.dart';
import '../views/my_events_page.dart';
import '../views/profile_page.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _selectedIndex = 0;

  // Initialize pages in a getter to avoid the issue
  List<Widget> get _pages => [
    HomeScreen(),
    MyEventsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            key: const ValueKey('home_icon_button'),
            icon: Icon(Icons.home, size: 32),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            key: const ValueKey('events_icon_button'),
            icon: Icon(Icons.event, size: 32),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            key: const ValueKey('profile_icon_button'),
            icon: Icon(Icons.person, size: 32),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
