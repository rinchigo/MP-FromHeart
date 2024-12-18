import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMenuPage extends StatefulWidget {
  @override
  _AddMenuPageState createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _itemDescription = '';
  double _itemPrice = 0.0;
  File? _itemImage;

  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 2; // For Bottom Navigation Bar

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _itemImage = File(pickedFile.path);
      });
    }
  }

  // Handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _itemImage != null) {
      _formKey.currentState!.save();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.41/fromheart-database/add_menu.php'),
      );

      request.fields['item_name'] = _itemName;
      request.fields['item_description'] = _itemDescription;
      request.fields['item_price'] = _itemPrice.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'item_image',
        _itemImage!.path,
      ));

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        if (response.statusCode == 200 && responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_itemName has been added!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to add item')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add an image!')),
      );
    }
  }

  // Navigation handler for BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation here (e.g., go to different screens)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Add New Menu Item'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Item Name
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    onSaved: (value) => _itemName = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter an item name' : null,
                  ),
                  const SizedBox(height: 10),

                  // Item Description
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Item Description'),
                    onSaved: (value) => _itemDescription = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 10),

                  // Item Price
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Item Price'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        _itemPrice = double.tryParse(value ?? '') ?? 0.0,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Image Section
                  _itemImage != null
                      ? Image.file(
                          _itemImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Text('No image selected',
                          style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),

                  // Image Picker Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        label: const Text('Gallery'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera),
                        label: const Text('Camera'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Add Item',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Offers'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
