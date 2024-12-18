import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.27'; // Ganti dengan URL backend Anda

  static Future<Map<String, dynamic>> uploadUserProfile({
    required String fullName,
    required String email,
    required String password,
    required String address,
    required String birthday,
    required String gender,
    required String nationality,
    required String job,
    required File? profileImage,
  }) async {
    final url = Uri.parse('$baseUrl/save_user.php');
    final request = http.MultipartRequest('POST', url);

    // Tambahkan data field
    request.fields['full_name'] = fullName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['address'] = address;
    request.fields['birthday'] = birthday;
    request.fields['gender'] = gender;
    request.fields['nationality'] = nationality;
    request.fields['job'] = job;

    // Tambahkan file gambar
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        profileImage.path,
      ));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        return {'success': false, 'message': 'Failed to upload profile picture'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
