class RemoteEventModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String status;

  RemoteEventModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
  });

  factory RemoteEventModel.fromMap(Map<String, dynamic> map) {
    return RemoteEventModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      status: map['status'] ?? '',
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