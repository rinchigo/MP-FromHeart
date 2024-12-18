import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountScreen extends StatefulWidget {
  final String email;

  const AccountScreen({Key? key, required this.email}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();

  String _selectedGender = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user data
  Future<void> _fetchUserData() async {
    final url = Uri.parse(
        'http://192.168.1.41/fromheart-database/get_user.php?email=${Uri.encodeComponent(widget.email)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            _userData = responseData['user'];
            _nameController.text = _userData!['full_name'] ?? '';
            _birthdayController.text = _userData!['birthday'] ?? '';
            _emailController.text = _userData!['email'] ?? '';
            _nationalityController.text = _userData!['nationality'] ?? '';
            _selectedGender = _userData!['gender'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          _showErrorSnackBar(responseData['message'] ?? 'Failed to load data');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Date picker for birthday
  Future<void> _selectBirthday() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = pickedDate.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Your Name *', _nameController),
                  const SizedBox(height: 12),
                  _buildGenderSelection(),
                  const SizedBox(height: 12),
                  _buildDateField('Birthday *', _birthdayController),
                  const SizedBox(height: 12),
                  _buildReadOnlyField('Email Address', _emailController),
                  const SizedBox(height: 12),
                  _buildDropdownField('Nationality', _nationalityController),
                  const SizedBox(height: 12),
                  _buildPINSection(),
                  const SizedBox(height: 20),
                  _buildDeleteAccountOption(),
                  const SizedBox(height: 20),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: Colors.grey.shade200,
        filled: true,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: _selectBirthday,
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender *', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildGenderRadio('Male', 'Male'),
            _buildGenderRadio('Female', 'Female'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderRadio(String label, String value) {
    return Expanded(
      child: ListTile(
        leading: Radio<String>(
          value: value,
          groupValue: _selectedGender,
          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
        ),
        title: Text(label),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller) {
    return DropdownButtonFormField<String>(
      value: controller.text,
      items: ['Indonesia', 'Malaysia', 'Singapore', 'Other']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) => controller.text = value ?? '',
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPINSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('PIN'),
      trailing: TextButton(
        onPressed: () {},
        child: const Text('Edit', style: TextStyle(color: Colors.green)),
      ),
    );
  }

  Widget _buildDeleteAccountOption() {
    return Row(
      children: const [
        Icon(Icons.delete_forever, color: Colors.red),
        SizedBox(width: 8),
        Text(
          'Delete FromHeart account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
