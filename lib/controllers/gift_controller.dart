import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/remote/remote_gift_model.dart';

class GiftController {
  final String userId;
  final String eventId;

  GiftController({required this.userId, required this.eventId});

  CollectionReference get _giftsCollection => FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .collection('Events')
      .doc(eventId)
      .collection('Gifts');

  Stream<List<RemoteGiftModel>> getGiftsStream() {
    return _giftsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) =>
            RemoteGiftModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)
        ).toList()
    );
  }

  Future<void> addGift({
    required String name,
    required String description,
    required double price,
    String? imageString,
  }) async {
    await _giftsCollection.add({
      'name': name,
      'description': description,
      'price': price,
      'imageString': imageString ?? '',
      'isPledged': false,
      'pledgerName': '',
      'pledgerId': '',
    });
  }

  Future<void> editGift({
    required String giftId,
    required String name,
    required String description,
    required double price,
    String? imageString,
  }) async {
    await _giftsCollection.doc(giftId).update({
      'name': name,
      'description': description,
      'price': price,
      'imageString': imageString ?? '',
    });
  }

  Future<void> deleteGift(String giftId) async {
    await _giftsCollection.doc(giftId).delete();
  }

  List<RemoteGiftModel> sortGifts(List<RemoteGiftModel> gifts, String sortBy) {
    switch (sortBy) {
      case 'name':
        gifts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        gifts.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
    return gifts;
  }
}