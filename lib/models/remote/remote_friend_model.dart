class RemoteFriendModel {
  // final String userId;
  final String friendUid;
  final String friendName;
  final String friendProfilePictureURL;

  RemoteFriendModel({
    // required this.userId,
    required this.friendUid,
    required this.friendName,
    this.friendProfilePictureURL = '',
  });

  // Convert a Friend object into a Map
  Map<String, dynamic> toMap() {
    return {
      // 'userId': userId,
      'friendUid': friendUid,
      'friendName': friendName,
      'friendProfilePictureURL': friendProfilePictureURL,
    };
  }

  // Create a Friend object from a Map
  factory RemoteFriendModel.fromMap(Map<String, dynamic> map) {
    return RemoteFriendModel(
      // userId: map['userId'],
      friendUid: map['friendUid'] ?? 'null_id',
      friendName: map['friendName'] ?? 'null_friend',
      friendProfilePictureURL: map['friendProfilePictureURL'] ?? 'assets/default.jpg',
    );
  }
}
