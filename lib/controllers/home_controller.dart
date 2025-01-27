import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/remote/remote_friend_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class HomeController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String username = 'User';
  bool _isSearching = false;
  List<RemoteFriendModel> friendsList = [];
  List<RemoteFriendModel> filteredFriends = [];

  bool get isSearching => _isSearching;

  void initialize() {
    _fetchUsername();
    _loadFriends();
  }

  Stream<List<Map<String, dynamic>>> streamUpcomingEvents(String friendUid) {
    return _firestoreService.getFriendEvents(friendUid);
  }

  Future<void> _fetchUsername() async {
    try {
      final fetchedUsername = await _firestoreService.getUsername(_authService.currentUserUid);
      username = fetchedUsername ?? 'User';
      notifyListeners();
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  void _loadFriends() async {
    try {
      final friends = await _firestoreService.getAllFriends(_authService.currentUserUid);
      friendsList = friends;
      filteredFriends = friends;
      notifyListeners();
    } catch (e) {
      print('Error loading friends: $e');
      friendsList = [];
      filteredFriends = [];
      notifyListeners();
    }
  }

  Future<int> fetchUpcomingEvents(String friendUid) async {
    try {
      final eventsCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(friendUid)
          .collection('Events');

      final querySnapshot = await eventsCollection.get();
      int upcomingEventCount = 0;
      DateTime now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        final eventData = doc.data();
        final eventDateStr = eventData['date'];

        if (eventDateStr != null) {
          try {
            DateTime eventDate = DateTime.parse(eventDateStr);
            if (eventDate.isAfter(now)) {
              upcomingEventCount++;
            }
          } catch (e) {
            print('Error parsing event date: $e');
          }
        }
      }

      return upcomingEventCount;
    } catch (e) {
      print('Error fetching events: $e');
      return 0;
    }
  }

  void filterFriends(String query) {
    filteredFriends = friendsList
        .where((friend) =>
        friend.friendName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      filteredFriends = friendsList;
    }
    notifyListeners();
  }
}