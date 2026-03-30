import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/paged_garment_response.dart';

class GarmentService {
  static const String baseUrl = 'http://127.0.0.1:8080';

  static Future<PagedGarmentResponse> getGarments({
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/garments?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PagedGarmentResponse.fromJson(data);
    } else {
      throw Exception('Failed to load garments');
    }
  }

  static Future<void> uploadGarment(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/garments'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload garment');
    }
  }

  static Future<void> deleteGarment(int garmentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/garments/$garmentId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete garment');
    }
  }
}
