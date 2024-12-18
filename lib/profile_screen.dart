import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;

  ProfileScreen({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _selectedGender = 'Female'; // Default gender selection
  }

  /// Show a mini-calendar to pick the date
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  /// Submit the form and upload profile data
  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.41/fromheart-database/save_user.php'),
      );

      request.fields['full_name'] = widget.fullName.trim();
      request.fields['email'] = widget.email.trim();
      request.fields['password'] = widget.password.trim();
      request.fields['address'] = _addressController.text.trim();
      request.fields['birthday'] = _birthdayController.text.trim();
      request.fields['gender'] = _selectedGender!;
      request.fields['nationality'] = _nationalityController.text.trim();

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _profileImage!.path,
        ));
      }

      try {
        setState(() {
          _isLoading = true;
        });

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        if (response.statusCode == 200 && responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to save profile')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
    }
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool isReadOnly = false,
    void Function()? onTap,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: child ??
                    TextFormField(
                      controller: controller,
                      readOnly: isReadOnly,
                      onTap: onTap,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter your $hint' : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Hello, ${widget.fullName}!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                widget.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildInputField(
                hint: 'Gender',
                icon: Icons.person,
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select your gender'
                      : null,
                ),
              ),
              _buildInputField(
                hint: 'Address',
                icon: Icons.location_on,
                controller: _addressController,
              ),
              _buildInputField(
                hint: 'Birthday',
                icon: Icons.calendar_today,
                controller: _birthdayController,
                isReadOnly: true,
                onTap: _selectDate,
              ),
              _buildInputField(
                hint: 'Nationality',
                icon: Icons.public,
                controller: _nationalityController,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
