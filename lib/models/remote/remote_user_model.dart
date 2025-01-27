class RemoteUserModel {
  final String uid; // Unique identifier
  final String username;
  final String email;
  final String profilePictureURL;
  final String phoneNumber;
  final DateTime createdAt;
  final String fcmToken;

  RemoteUserModel({
    this.uid = '',
    required this.username,
    required this.email,
    this.profilePictureURL = 'assets/default.jpg',
    this.phoneNumber = '',
    required this.createdAt,
    this.fcmToken = '',
  });

  // Convert a User object into a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profilePictureURL': profilePictureURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  // Create a User object from a Map
  factory RemoteUserModel.fromMap(Map<String, dynamic> map) {
    return RemoteUserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? 'Guest',
      email: map['email'] ?? '',
      profilePictureURL: map['profilePictureURL'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now()),
      fcmToken: map['fcmToken'] ?? '',
    );
  }
}
