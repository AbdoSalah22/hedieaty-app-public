class LocalUserModel {
  final String id;
  final String username;
  final String profilePictureURL;
  final bool isSynced;

  LocalUserModel({
    required this.id,
    required this.username,
    required this.profilePictureURL,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profilePictureURL': profilePictureURL,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory LocalUserModel.fromMap(Map<String, dynamic> map) {
    return LocalUserModel(
      id: map['id'],
      username: map['username'],
      profilePictureURL: map['profilePictureURL'],
      isSynced: map['isSynced'] == 1,
    );
  }
}