import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'friend_events_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late HomeController _controller;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _addFriendAnimationController;
  late Animation<double> _addFriendAnimation;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();

    // Animation setup
    _addFriendAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addFriendAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _addFriendAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  // I don't know how to do this function with MVC architecture because it deals with both the view and services
  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController usernameController = TextEditingController();

        return ScaleTransition(
          scale: _addFriendAnimation,
          child: AlertDialog(
            backgroundColor: Color(0xFFFFF3E0), // Soft amber background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.deepOrange.shade200, width: 2),
            ),
            title: Text(
              'Add Friend',
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              key: const ValueKey('add_friend_field'),
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Enter friend\'s username',
                labelStyle: TextStyle(color: Colors.deepOrange.shade700),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade300, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.deepOrange.shade700),
                ),
              ),
              ElevatedButton(
                key: const ValueKey('add_friend_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                ),
                onPressed: () async {
                  final FirebaseAuthService _authService = FirebaseAuthService();
                  final FirestoreService _firestoreService = FirestoreService();
                  final username = usernameController.text;
                  if (username.isNotEmpty) {
                    try {
                      await _firestoreService.addFriend(_authService.currentUserUid, username);
                      Navigator.pop(context);
                      try {
                        final friends = await _firestoreService.getAllFriends(_authService.currentUserUid);
                        setState(() {
                          _controller.friendsList = friends;
                          _controller.filteredFriends = friends;
                        });
                      } catch (e) {
                        print('Error loading friends: $e');
                        setState(() {
                          _controller.friendsList = [];
                          _controller.filteredFriends = [];
                        });
                      }
                      print('Friend added');
                    } catch (e) {
                      print('Error: $e');
                    }
                  }
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGreetingText(),
              // SizedBox(height: 16),
              // _buildCreateEventButton(),
              SizedBox(height: 16),
              _buildFriendsHeader(),
              if (_controller.isSearching)
                _buildSearchField(),
              _buildFriendsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingText() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Welcome, ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
              color: Colors.teal.shade700,
            ),
          ),
          TextSpan(
            text: _controller.username,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        // Add your event logic here
      },
      child: Text(
        'Create Your Own Event',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFriendsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Friends',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange.shade700,
          ),
        ),
        Row(
          children: [
            IconButton(
              key: const ValueKey('plus_icon_button'),
              icon: Icon(Icons.add, color: Colors.teal.shade800),
              iconSize: 32,
              onPressed: () {
                _addFriendAnimationController.forward(from: 0);
                _showAddFriendDialog();
              },
            ),
            IconButton(
              key: const ValueKey('search_icon_button'),
              icon: Icon(Icons.search, color: Colors.deepOrange.shade700),
              iconSize: 28,
              onPressed: () => _controller.toggleSearch(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      key: const ValueKey('search_friend_field'),
      controller: _searchController,
      onChanged: _controller.filterFriends,
      decoration: InputDecoration(
        hintText: 'Search friends...',
        hintStyle: TextStyle(color: Colors.teal.shade700),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange.shade200),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: _controller.filteredFriends.isEmpty
          ? Center(
        child: Text(
          'No friends found.',
          style: TextStyle(
            color: Colors.deepOrange.shade700,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _controller.filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = _controller.filteredFriends[index];
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _controller.streamUpcomingEvents(friend.friendUid),
            builder: (context, snapshot) {
              final eventCount = snapshot.data?.length ?? 0;
              final eventText = (eventCount > 0)
                  ? 'Upcoming Events: $eventCount'
                  : 'No Upcoming Events';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendEventsPage(
                        friendUid: friend.friendUid,
                        friendName: friend.friendName,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade600,
                        Colors.teal.shade300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                        friend.friendProfilePictureURL.isEmpty
                            ? 'assets/default.jpg'
                            : friend.friendProfilePictureURL,
                      ),
                    ),
                    title: Text(
                      friend.friendName,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      eventText,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: eventCount > 0
                            ? Colors.deepOrange.shade800
                            : Colors.teal.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$eventCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    _addFriendAnimationController.dispose();
    super.dispose();
  }
}