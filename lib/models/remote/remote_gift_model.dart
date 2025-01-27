class RemoteGiftModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageString;
  final bool isPledged;
  final String pledgerName;
  final String pledgerId;

  RemoteGiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageString = '',
    this.isPledged = false,
    this.pledgerName = '',
    this.pledgerId = '',
  });

  factory RemoteGiftModel.fromMap(String id, Map<String, dynamic> map) {
    return RemoteGiftModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'].toDouble(),
      imageString: map['imageString'] ?? '',
      isPledged: map['isPledged'] ?? false,
      pledgerName: map['pledgerName'] ?? '',
      pledgerId: map['pledgerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageString': imageString,
      'isPledged': isPledged,
      'pledgerName': pledgerName,
      'pledgerId': pledgerId,
    };
  }
}