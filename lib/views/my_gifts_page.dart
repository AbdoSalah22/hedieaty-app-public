import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/remote/remote_gift_model.dart';
import '../utils/image_converter.dart';

class MyGiftsPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final String eventName;

  const MyGiftsPage({
    Key? key,
    required this.userId,
    required this.eventId,
    required this.eventName
  }) : super(key: key);

  @override
  _MyGiftsPageState createState() => _MyGiftsPageState();
}

class _MyGiftsPageState extends State<MyGiftsPage> {
  late GiftController _giftController;
  String _sortBy = 'name'; // Default sorting

  @override
  void initState() {
    super.initState();
    _giftController = GiftController(
        userId: widget.userId,
        eventId: widget.eventId
    );
  }

  void _addGift() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageConverter = ImageConverter();
    String? imageString;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Add Gift",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(nameController, "Gift Name", Icons.card_giftcard),
                  const SizedBox(height: 15),
                  _buildTextField(descriptionController, "Description", Icons.description),
                  const SizedBox(height: 15),
                  _buildTextField(priceController, "Price", Icons.attach_money, isNumeric: true),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: imageString == null ? Colors.teal : Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      imageString = await imageConverter.pickAndCompressImageToString();
                      setState(() {}); // Update the UI within the dialog
                    },
                    icon: Icon(
                      imageString == null ? Icons.image : Icons.check_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      imageString == null ? "Pick Image" : "Image Selected",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (imageString != null) ...[
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        imageConverter.stringToImage(imageString!)!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  final price = double.tryParse(priceController.text.trim());

                  if (_validateInputs(name, description, price)) {
                    _giftController.addGift(
                      name: name,
                      description: description,
                      price: price!,
                      imageString: imageString,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "Add",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _editGift(RemoteGiftModel gift) {
    final nameController = TextEditingController(text: gift.name);
    final descriptionController = TextEditingController(text: gift.description);
    final priceController = TextEditingController(text: gift.price.toString());

    showDialog(
      context: context,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Edit Gift",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Gift Name", Icons.card_giftcard),
              const SizedBox(height: 10),
              _buildTextField(descriptionController, "Description", Icons.description),
              const SizedBox(height: 10),
              _buildTextField(priceController, "Price", Icons.attach_money, isNumeric: true),
            ],
          ),
          actions: [
            _buildDialogButton(
              text: "Cancel",
              onPressed: () => Navigator.of(context).pop(),
              isPrimary: false,
            ),
            _buildDialogButton(
              text: "Save",
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final price = double.tryParse(priceController.text.trim());

                if (_validateInputs(name, description, price)) {
                  _giftController.editGift(
                      giftId: gift.id,
                      name: name,
                      description: description,
                      price: price!
                  );
                  Navigator.of(context).pop();
                }
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGift(RemoteGiftModel gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this gift?"),
        actions: [
          _buildDialogButton(
            text: "Cancel",
            onPressed: () => Navigator.of(context).pop(),
            isPrimary: false,
          ),
          _buildDialogButton(
            text: "Delete",
            onPressed: () {
              _giftController.deleteGift(gift.id);
              Navigator.of(context).pop();
            },
            isPrimary: true,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // Utility method to build text fields
  TextField _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool isNumeric = false}
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }

  // Utility method to build dialog buttons
  TextButton _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isPrimary
            ? Colors.white
            : (isDestructive ? Colors.red : Colors.teal),
        backgroundColor: isPrimary
            ? Colors.deepOrange
            : (isDestructive ? Colors.deepOrange.shade50 : Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(text),
    );
  }

  // Input validation
  bool _validateInputs(String name, String description, double? price) {
    if (name.isEmpty || description.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields must be filled in correctly.")),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'price',
                child: Text('Sort by Price'),
              ),
              const PopupMenuItem<String>(
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<RemoteGiftModel>>(
        stream: _giftController.getGiftsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No gifts available."));
          }

          // Sort gifts
          List<RemoteGiftModel> gifts = _sortGifts(snapshot.data!);

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: gift.isPledged ? Colors.teal.shade200 : Colors.red.shade200,
                    width: 1.5,
                  ),
                ),
                color: gift.isPledged ? Colors.teal.shade50 : Colors.red.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0), // Adjust as desired
                    child: gift.imageString.isNotEmpty
                        ? Image.memory(
                      ImageConverter().stringToImage(gift.imageString)!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/gift.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    gift.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gift.isPledged ? Colors.teal.shade800 : Colors.red.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.description,
                        style: TextStyle(
                          color: gift.isPledged ? Colors.teal.shade600 : Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EGP: ${gift.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: gift.isPledged ? Colors.teal.shade700 : Colors.deepOrange.shade700,
                        ),
                      ),
                    ],
                  ),
                  trailing: gift.isPledged
                      ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pledged',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.teal.shade800),
                        onPressed: () => _editGift(gift),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.deepOrange.shade800),
                        onPressed: () => _deleteGift(gift),
                      ),
                    ],
                  ),
                ),
              );

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGift,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add Gift',
      ),
    );
  }

  List<RemoteGiftModel> _sortGifts(List<RemoteGiftModel> gifts) {
    switch (_sortBy) {
      case 'name':
        gifts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        gifts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'status':
        gifts.sort((a, b) => a.isPledged == b.isPledged ? 0 : (a.isPledged ? 1 : -1));
        break;
    }
    return gifts;
  }
}
