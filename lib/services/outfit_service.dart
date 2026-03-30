import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/paged_outfit_response.dart';

class OutfitService {
  static const String baseUrl = 'http://127.0.0.1:8080';

  static Future<PagedOutfitResponse> getOutfits({
    int page = 0,
    int size = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/outfits?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PagedOutfitResponse.fromJson(data);
    } else {
      throw Exception('Failed to load outfits');
    }
  }

  static Future<void> uploadOutfit(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/outfits'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload outfit');
    }
  }

  static Future<void> deleteOutfit(int outfitId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/outfits/$outfitId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete outfit');
    }
  }
}
