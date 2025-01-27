import 'package:flutter/material.dart';
import 'package:hedieaty/models/remote/remote_event_model.dart';
import '../services/firestore_service.dart';

class EventsController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String sortBy = 'name';
  List<RemoteEventModel> events = [];

  Future<List<RemoteEventModel>> fetchEvents() async {
    events = await _firestoreService.getUserEvents(sortBy)
        .then((eventMaps) => eventMaps.map((map) => RemoteEventModel.fromMap(map)).toList());
    notifyListeners();
    return events;
  }

  void sortEvents(String criteria) {
    sortBy = criteria;
    notifyListeners();
  }

  Future<void> addEvent(RemoteEventModel event) async {
    await _firestoreService.addEvent(event.toMap());
    await fetchEvents();
  }

  Future<void> editEvent(String eventId, RemoteEventModel event) async {
    await _firestoreService.editEvent(eventId, event.toMap());
    await fetchEvents();
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.deleteEvent(eventId);
    await fetchEvents();
  }

  String determineEventStatus(DateTime selectedDate) {
    final now = DateTime.now();
    if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Past';
    } else if (selectedDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      return 'Current';
    } else {
      return 'Upcoming';
    }
  }
}