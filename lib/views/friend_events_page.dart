import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/remote/remote_event_model.dart';
import 'friend_gifts_page.dart';

class FriendEventsPage extends StatefulWidget {
  final String friendName;
  final String friendUid;

  const FriendEventsPage({
    Key? key,
    required this.friendName,
    required this.friendUid,
  }) : super(key: key);

  @override
  _FriendEventsPageState createState() => _FriendEventsPageState();
}

class _FriendEventsPageState extends State<FriendEventsPage> {
  late String friendName;
  late String friendUid;

  @override
  void initState() {
    super.initState();
    friendName = widget.friendName;
    friendUid = widget.friendUid;
  }

  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  String sortBy = 'name';

  Stream<List<RemoteEventModel>> _fetchEvents() {
    return _firestoreService.getFriendEvents(friendUid).map((eventMaps) {
      return eventMaps.map((map) => RemoteEventModel.fromMap(map)).toList();
    });
  }

  void _sortEvents(String criteria) {
    setState(() {
      sortBy = criteria;
    });
  }

  String _determineEventStatus(DateTime selectedDate) {
    final now = DateTime.now();
    if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Past';
    } else if (selectedDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      return 'Current';
    } else {
      return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Sort
              _buildHeader(),

              // Event List
              Expanded(
                child: StreamBuilder<List<RemoteEventModel>>(
                  stream: _fetchEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.teal,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No events found.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      );
                    }

                    final events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(event);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              key: const ValueKey('arrow_back_icon_button'),
              icon: Icon(Icons.arrow_back, color: Colors.teal),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              '${friendName}\'s Events',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: _sortEvents,
          icon: Icon(Icons.sort, color: Colors.teal),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'name', child: Text('Sort by Name')),
            PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            PopupMenuItem(value: 'status', child: Text('Sort by Status')),
          ],
        ),
      ],
    );
  }


  Widget _buildEventCard(RemoteEventModel event) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          event.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.description, color: Colors.teal, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.description,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.teal, size: 16),
                SizedBox(width: 4),
                Text(
                  DateFormat('dd-MM-yyyy').format(event.date),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendGiftsPage(
                friendUid: friendUid,
                eventId: event.id!,
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Past':
        return Colors.grey;
      case 'Current':
        return Colors.green;
      case 'Upcoming':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }
}

class EventDialog extends StatefulWidget {
  final RemoteEventModel? event;
  final Function(RemoteEventModel) onSave;
  final String Function(DateTime) determineStatus;

  const EventDialog({
    Key? key,
    this.event,
    required this.onSave,
    required this.determineStatus,
  }) : super(key: key);

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.event?.name ?? '');
    descriptionController = TextEditingController(text: widget.event?.description ?? '');
    locationController = TextEditingController(text: widget.event?.location ?? '');
    selectedDate = widget.event?.date;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        widget.event == null ? 'Add Event' : 'Edit Event',
        style: TextStyle(color: Colors.teal),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.teal),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.teal),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(color: Colors.teal),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'No Date Chosen'
                        : 'Selected Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: Text('Choose Date', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.teal)),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: Text('Save', style: TextStyle(color: Colors.red)),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveEvent() {
    if (nameController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields and choose a date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final status = widget.determineStatus(selectedDate!);

    final eventModel = RemoteEventModel(
      id: widget.event?.id ?? '',
      name: nameController.text,
      description: descriptionController.text,
      location: locationController.text,
      date: selectedDate!,
      status: status,
    );

    widget.onSave(eventModel);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }
}