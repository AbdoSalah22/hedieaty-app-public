class LocalEventModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final int isSynced;
  final String userId;

  LocalEventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    required this.isSynced,
    required this.userId
  });

  factory LocalEventModel.fromMap(Map<String, dynamic> map) {
    return LocalEventModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      status: map['status'] ?? '',
      isSynced: map['isSynced'],
      userId: map['userId']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}