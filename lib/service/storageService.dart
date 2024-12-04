import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bag_a_moment/model/searchModel.dart';

class StorageService {
  final String baseUrl = 'http://3.35.175.114:8080';

  Future<List<searchModel>> fetchStorages({
    required double latitude,
    required double longitude,
    required int radius,
    required String searchTerm,
  }) async {
    final url =
        '$baseUrl/storages/search?latitude=$latitude&longitude=$longitude&radius=$radius&searchTerm=$searchTerm';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['isSuccess'] == true) {
          final List<dynamic> data = responseBody['data'];
          return data.map((item) => searchModel.fromJson(item)).toList();
        } else {
          throw Exception(responseBody['message']);
        }
      } else {
        throw Exception('Failed to load storages with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching storages: $e');
    }
  }
}
