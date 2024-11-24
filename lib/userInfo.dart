import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Userinfo {
  static const String baseUrl = 'http://3.35.175.114:8080'; // 서버 기본 URL
  static final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure Storage

  // 로그인 토큰 읽기
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // 사용자 ID 추출 (JWT 디코딩)
  static Future<int?> extractUserIdFromToken() async {
    final token = await getAuthToken();
    if (token == null) return null;

    try {
      final payload = token.split('.')[1]; // JWT의 Payload 추출
      final normalized = base64.normalize(payload);
      final decodedPayload = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decodedPayload);

      return payloadMap['id'] as int?;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('로그인 토큰이 없습니다.');
      }

      final userId = await extractUserIdFromToken();
      if (userId == null) {
        throw Exception('토큰에서 사용자 ID를 추출할 수 없습니다.');
      }

      final url = '$baseUrl/users/$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
