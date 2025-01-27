import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/remote/remote_gift_model.dart';
import '../services/google_cloud_api.dart';
import 'package:http/http.dart' as http;

class FriendGiftsPage extends StatefulWidget {
  final String friendUid;
  final String eventId;

  const FriendGiftsPage({
    required this.friendUid,
    required this.eventId,
    Key? key,
  }) : super(key: key);

  @override
  _FriendGiftsPageState createState() => _FriendGiftsPageState();
}

class _FriendGiftsPageState extends State<FriendGiftsPage> {
  late Stream<QuerySnapshot> _giftsStream;

  @override
  void initState() {
    super.initState();
    _giftsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.friendUid)
        .collection('Events')
        .doc(widget.eventId)
        .collection('Gifts')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Gifts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _giftsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.deepOrange.shade300),
                  const SizedBox(height: 16),
                  const Text('Error loading gifts'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 48, color: Colors.teal.shade300),
                  const SizedBox(height: 16),
                  const Text('No gifts found'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 320,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final giftData = doc.data() as Map<String, dynamic>;
              final gift = RemoteGiftModel.fromMap(doc.id, giftData);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.2,  // This maintains a consistent image ratio
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: gift.imageString.isNotEmpty
                            ? Image.memory(
                          base64Decode(gift.imageString),
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/gift.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gift.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gift.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'EGP: ${gift.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const ValueKey('pledge_gift_button'),
                              onPressed: gift.isPledged
                                  ? null
                                  : () async {
                                final shouldPledge = await _showConfirmationDialog(
                                    context);
                                if (shouldPledge == true) {
                                  await _pledgeGift(
                                      widget.friendUid, widget.eventId, gift.id);
                                }
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gift.isPledged ? Colors.teal : Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text(
                                gift.isPledged ? 'Pledged' : 'Pledge Gift',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pledge'),
        content: const Text('Are you sure you want to commit to this gift?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('confirm_button'),
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: Text(
                'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pledgeGift(String friendUid, String eventId, String giftId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('User not logged in');
      return;
    }

    try {
      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      final username = userDoc.data()?['username'] ?? 'Anonymous';

      // Reference to the gift
      final giftRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(friendUid)
          .collection('Events')
          .doc(eventId)
          .collection('Gifts')
          .doc(giftId);

      // Update the gift as pledged
      await giftRef.update({
        'isPledged': true,
        'pledgerId': currentUser.uid,
        'pledgerName': username,
      });

      // Add to the user's "Pledged Gifts" sub-collection
      final pledgedGiftRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Pledged Gifts')
          .doc(giftId);

      await pledgedGiftRef.set({
        'eventId': eventId,
        'friendUid': friendUid,
        'giftId': giftId,
        'pledgedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the recipient's FCM token
      final recipientDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(friendUid)
          .get();
      final recipientToken = recipientDoc.data()?['fcmToken'];

      if (recipientToken != null) {
        await _sendFCMNotification(recipientToken, username, giftId);
      }

      print('Gift pledged and added to Pledged Gifts');
    } catch (e) {
      print('Error pledging gift: $e');
    }
  }

  Future<void> _sendFCMNotification(String recipientToken, String pledgerName,
      String giftId) async {
    final url =
    Uri.parse(
        'https://fcm.googleapis.com/v1/projects/hedieaty-firebase/messages:send');

    // Retrieve the OAuth 2.0 access token for the FCM API
    final String accessToken = await getAccessToken(); // Replace with your token logic

    // Updated payload structure for FCM V1 API
    final notificationData = {
      'message': {
        'token': recipientToken,
        'notification': {
          'title': 'Gift Pledged!',
          'body': '$pledgerName pledged a gift for you!',
        },
        'data': {
          'giftId': giftId,
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
