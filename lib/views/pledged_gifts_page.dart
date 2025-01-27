import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/remote/remote_gift_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/image_converter.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final ImageConverter _imageConverter = ImageConverter();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Pledged Gifts'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'You need to log in to view your pledged gifts',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Pledged Gifts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Pledged Gifts')
            .orderBy('pledgedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading pledged gifts',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pledged gifts found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final pledgedGifts = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final pledgedGift = pledgedGifts[index].data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(pledgedGift['friendUid'])
                    .collection('Events')
                    .doc(pledgedGift['eventId'])
                    .collection('Gifts')
                    .doc(pledgedGift['giftId'])
                    .get(),
                builder: (context, giftSnapshot) {
                  if (giftSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }

                  if (giftSnapshot.hasError || !giftSnapshot.hasData || !giftSnapshot.data!.exists) {
                    return _buildErrorCard();
                  }

                  final giftData = giftSnapshot.data!.data() as Map<String, dynamic>;
                  final gift = RemoteGiftModel.fromMap(
                    pledgedGift['giftId'],
                    giftData
                  );

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left side - Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            child: SizedBox(
                              width: 120,
                              child: gift.imageString.isNotEmpty
                                  ? Image.memory(
                                _imageConverter.stringToImage(gift.imageString)!,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                'assets/gift.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Right side - Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gift Name
                                  Text(
                                    gift.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Description
                                  Expanded(
                                    child: Text(
                                      gift.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Price Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'EGP ${gift.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.teal.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 12,
                                          color: Colors.teal.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        FutureBuilder<String>(
                                          future: _firestoreService.getUsername(pledgedGift['friendUid']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const SizedBox( // Use SizedBox for consistent spacing
                                                width: 16, // Adjust width as needed
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2, // Make the indicator smaller
                                                  color: Colors.teal,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                'Error', // Display a short error message
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            } else if (snapshot.hasData) {
                                              return Text(
                                                snapshot.data!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.teal.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                'Unknown', // Handle missing username
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Unpledge Button
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              tooltip: 'Unpledge Gift',
                              onPressed: () async {
                                // Update gift fields
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(pledgedGift['friendUid'])
                                    .collection('Events')
                                    .doc(pledgedGift['eventId'])
                                    .collection('Gifts')
                                    .doc(pledgedGift['giftId'])
                                    .update({
                                  'pledgerName': '',
                                  'pledgerId': '',
                                  'isPledged': false,
                                });

                                // Remove from Pledged Gifts collection
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(_authService.currentUserUid)
                                    .collection('Pledged Gifts')
                                    .doc(pledgedGift['giftId'])
                                    .delete();

                                // Remove the Card from the list
                                setState(() {
                                  pledgedGifts.removeWhere((gift) => gift['giftId'] == pledgedGift['giftId']);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gift unpledged successfully.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gift no longer available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Details could not be retrieved',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}