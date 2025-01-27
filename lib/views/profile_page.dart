import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/login_page.dart';
import 'package:hedieaty/views/pledged_gifts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/database/database_helper.dart';

import '../services/firebase_auth_service.dart';

class ProfilePage extends StatefulWidget {

  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _notificationsEnabled = false;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  String userName = 'Your Name';
  String profileImageUrl = 'assets/default.png'; // Default profile image
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  StreamSubscription? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // _syncWithFirestore();
      }
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final localData = await dbHelper.getLocalUser(_authService.currentUserUid);

    try {
      if (localData != null) {
        setState(() {
          userName = localData['username'];
          profileImageUrl = localData['profilePictureURL'];
        });
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_authService.currentUserUid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          userName = data['username'];
          profileImageUrl = data['profilePictureURL'];
        });

        // Update local DB
        await dbHelper.insertOrUpdateUser({
          'id': _authService.currentUserUid,
          'username': data['username'],
          'profilePictureURL': data['profilePictureURL'],
          'isSynced': 1
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateProfileImage(String newImageUrl) async {
    setState(() {
      profileImageUrl = newImageUrl;
    });

    await dbHelper.insertOrUpdateUser({
      'id': _authService.currentUserUid,
      'username': userName,
      'profilePictureURL': newImageUrl,
      'isSynced': 0
    });

    // Sync with Firestore if online
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_authService.currentUserUid)
          .update({'profilePictureURL': newImageUrl});

      await dbHelper.markUserAsSynced(_authService.currentUserUid);
    }
  }


  Future<void> _syncWithFirestore() async {
    final unsyncedUsers = await dbHelper.getUnsyncedUsers();

    for (final user in unsyncedUsers) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user['id'])
            .update({
          // 'username': user['username'],
          'profilePictureURL': user['profilePictureURL']
        });

        await dbHelper.markUserAsSynced(user['id']);
      } catch (e) {
        print('Error syncing user data: $e');
      }
    }
  }


  void _showImagePicker() {
    final List<String> profileImages = [
      'assets/profile1.png',
      'assets/profile2.png',
      'assets/profile3.png',
      'assets/profile4.png'
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Choose Profile Image",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: profileImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _updateProfileImage(profileImages[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(profileImages[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToPledgedGifts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => PledgedGiftsPage(userId: widget.userId),
        builder: (context) => PledgedGiftsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Profile Image
              GestureDetector(
                onTap: _showImagePicker,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 80, // Increased size
                      backgroundImage: AssetImage(profileImageUrl),
                      backgroundColor: Colors.teal.shade50,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Username with Copy Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.teal),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Username copied to clipboard')),
                        );
                        // Add clipboard functionality here
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Notifications Toggle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined, color: Colors.teal),
                    SizedBox(width: 12),
                    Text(
                      'Enable Notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                          // Call your enableNotifications method here
                          // enableNotifications(value);
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Pledged Gifts Button
              Container(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  key: const ValueKey('my_pledged_gifts_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _navigateToPledgedGifts,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, size: 30, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'My Pledged Gifts',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Sign Out Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Sign Out', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Sign Out', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Sign Out', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
