import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/remote/remote_friend_model.dart';
import 'package:hedieaty/models/remote/remote_user_model.dart';
import 'firebase_auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty; // True if no matching usernames
  }

  Future<void> addUser(RemoteUserModel user) async {
      await _firestore.collection('Users').doc(user.uid).set(user.toMap());
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('Users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<String> getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>; // Cast data to Map
        return data['username'] ?? 'User';
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      print('Error fetching username: $e');
      return 'User';
    }
  }

  Future<void> updateUserFCMToken(String uid, String token) async {
    await _firestore.collection('Users').doc(uid).update({'fcmToken': token});
  }

  Future<Map<String, dynamic>?> _searchUserByUsername(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null; // User not found
      }
    } catch (e) {
      print('Error searching user by username: $e');
      return null;
    }
  }

  Future<void> addFriend(String currentUserId, String friendUsername) async {
    try {
      // Search for the user by username
      final friendData = await _searchUserByUsername(friendUsername);

      if (friendData == null) {
        throw Exception('User not found');
      }

      final friendUid = friendData['uid'];

      if (currentUserId == friendUid){
        throw Exception('Can not add yourself');
      }

      // Check if the friend is already added
      final existingFriend = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('Friends')
          .doc(friendUid)
          .get();

      if (existingFriend.exists) {
        throw Exception('Friend already added');
      }

      // Add friend to the current user's Friends subcollection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('Friends')
          .doc(friendUid)
          .set({
        'friendUid': friendUid,
      });

      // Add user to friend's Friends subcollection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(friendUid)
          .collection('Friends')
          .doc(currentUserId)
          .set({
        'friendUid': currentUserId,
      });

      print('Friend added successfully!');
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<List<RemoteFriendModel>> getAllFriends(String currentUserId) async {
    try {
      final friendSnapshots = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('Friends')
          .get();

      List<RemoteFriendModel> friends = [];

      for (var friendDoc in friendSnapshots.docs) {
        final friendUid = friendDoc.data()['friendUid'];
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(friendUid)
            .get();

        print("FRIEND FOUND");

        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          friends.add(RemoteFriendModel(
            friendUid: friendUid,
            friendName: userData?['username'] ?? 'Unknown',
            friendProfilePictureURL: userData?['profilePictureURL'] ?? '',
          ));
        }
      }

      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getFriendEvents(String friendUid) {
    try {
      final eventsCollection = _firestore
          .collection('Users')
          .doc(friendUid)
          .collection('Events');

      return eventsCollection.snapshots().map((querySnapshot) {
        DateTime now = DateTime.now();

        // Filter and return upcoming events
        final upcomingEvents = querySnapshot.docs
            .where((doc) {
          final data = doc.data();
          if (data.containsKey('date') && data['date'] != null) {
            try {
              DateTime eventDate = DateTime.parse(data['date']);
              return eventDate.isAfter(now); // Only future events
            } catch (e) {
              print('Error parsing event date for ${doc.id}: $e');
              return false;
            }
          }
          return false;
        })
            .map((doc) => {
          ...doc.data(),
          'id': doc.id,
        }).toList();

        return upcomingEvents;
      });
    } catch (e) {
      print('Error fetching events for friend $friendUid: $e');
      return Stream.value([]); // Return an empty stream in case of an error
    }
  }


  Future<List<Map<String, dynamic>>> getUserEvents(String sortBy) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    final snapshot = await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Events')
        .orderBy(sortBy)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include the document ID for later reference
      return data;
    }).toList();
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    // Create a reference with auto-generated ID
    final docRef = _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Events')
        .doc();

    // Add ID to event data
    eventData['id'] = docRef.id;

    // Set the document with the ID included
    await docRef.set(eventData);
  }

  Future<void> editEvent(String eventId, Map<String, dynamic> updatedData) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Events')
        .doc(eventId)
        .update(updatedData);
  }

  Future<void> deleteEvent(String eventId) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Events')
        .doc(eventId)
        .delete();
  }
}
