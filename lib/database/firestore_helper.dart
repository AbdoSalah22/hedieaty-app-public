import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/remote/remote_user_model.dart';
import '../models/remote/remote_friend_model.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreHelper._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection Reference
  CollectionReference get usersRef => _firestore.collection('Users');

  // // Events Collection Reference
  // CollectionReference get eventsRef => _firestore.collection('Events');
  //
  // // Gifts Collection Reference
  // CollectionReference get giftsRef => _firestore.collection('Gifts');

  // Friends Collection Reference
  CollectionReference get friendsRef => _firestore.collection('Friends');

  // ----- USERS -----
  Future<void> addUser(RemoteUserModel user) async {
    await usersRef.doc(user.uid).set(user.toMap());
  }

  Future<RemoteUserModel?> getUser(String uid) async {
    try {
      final doc = await usersRef.doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return RemoteUserModel.fromMap(data);
        } else {
          print('User data is null for UID: $uid');
        }
      } else {
        print('No document found for UID: $uid');
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null; // Return null if no user is found or an error occurs
  }


  Future<List<RemoteUserModel>> getAllUsers() async {
    final querySnapshot = await usersRef.get();
    return querySnapshot.docs
        .map((doc) => RemoteUserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String uid) async {
    await usersRef.doc(uid).delete();
  }



  // Method to get the username of the currently signed-in user
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

  // Method to get the count of upcoming events for a friend
  Future<int> getUpcomingEventsCount(String friendId) async {
    try {
      QuerySnapshot eventsQuery = await _firestore
          .collection('Users')
          .doc(friendId)
          .collection('Events')
          .where('date', isGreaterThan: DateTime.now())
          .get();
      return eventsQuery.docs.length;
    } catch (e) {
      print('Error fetching upcoming events count: $e');
      return 0;
    }
  }





  // ----- EVENTS -----
  // Fetch events for the signed-in user
  Future<List<Map<String, dynamic>>> getUserEvents(String sortBy) async {
    final user = _auth.currentUser;
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
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID for later reference
      return data;
    }).toList();
  }

  // Add a new event
  Future<void> addEvent(Map<String, dynamic> eventData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not signed in.");
    }

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Events')
        .add(eventData);
  }

  // Edit an existing event
  Future<void> editEvent(String eventId, Map<String, dynamic> updatedData) async {
    final user = _auth.currentUser;
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

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    final user = _auth.currentUser;
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

  // // ----- GIFTS -----
  // Future<void> addGift(Gift gift) async {
  //   await giftsRef.doc(gift.id.toString()).set(gift.toMap());
  // }
  //
  // Future<List<Gift>> getGiftsForEvent(String eventId) async {
  //   final querySnapshot = await giftsRef.where('eventId', isEqualTo: eventId).get();
  //   return querySnapshot.docs
  //       .map((doc) => Gift.fromMap(doc.data() as Map<String, dynamic>))
  //       .toList();
  // }
  //
  // Future<void> deleteGift(String id) async {
  //   await giftsRef.doc(id).delete();
  // }

  // ----- FRIENDS -----
  Future<String?> getUsernameByCurrentUser() async {
    try {
      // Assuming you have a 'users' collection with documents using UID as document ID
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      return userDoc.exists ? userDoc['username'] : null;
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchUserByUsername(String username) async {
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

  // Add a friend for a specific user
  Future<void> addFriend(String currentUserId, String friendUsername) async {
    try {
      // Search for the user by username
      final friendData = await searchUserByUsername(friendUsername);

      if (friendData == null) {
        throw Exception('User not found');
      }

      final friendUid = friendData['uid'];

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
        'friendUid': friendUid, // Only store friendUid
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

  /// Fetches all upcoming events for a given friend's UID.
  Future<List<Map<String, dynamic>>> getFriendEvents(String friendUid) async {
    try {
      // Reference the friend's `Events` sub-collection
      final eventsCollection = _firestore
          .collection('Users')
          .doc(friendUid)
          .collection('Events');

      // Fetch all events
      final querySnapshot = await eventsCollection.get();

      // Get the current date for comparison
      DateTime now = DateTime.now();

      // Filter and return upcoming events
      final upcomingEvents = querySnapshot.docs
          .where((doc) {
        final data = doc.data();
        if (data.containsKey('date') && data['date'] != null) {
          try {
            // Parse the event date
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
        'id': doc.id, // Include the document ID
      })
          .toList();

      return upcomingEvents;
    } catch (e) {
      print('Error fetching events for friend $friendUid: $e');
      return []; // Return an empty list on error
    }
  }

  // Future<void> deleteFriend(String userId, String friendId) async {
  //   await friendsRef.doc(userId).collection('Friends').doc(friendId).delete();
  // }

  // // Utility for syncing with SQLite
  // Future<List<T>> syncCollection<T>({
  //   required CollectionReference collection,
  //   required T Function(Map<String, dynamic>) fromMap,
  // }) async {
  //   final querySnapshot = await collection.get();
  //   return querySnapshot.docs
  //       .map((doc) => fromMap(doc.data() as Map<String, dynamic>))
  //       .toList();
  // }
}
