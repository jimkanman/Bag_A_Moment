import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String BASE_URL = "http://3.35.175.114:8080";

  ApiService();

  Future<T> get<T>(String endpoint, {Map<String, String>? headers, required T Function(dynamic) fromJson}) async {
    print("ApiService: GET to '$BASE_URL/$endpoint");
    final response = await http.get(Uri.parse('$BASE_URL/$endpoint'), headers: headers);
    String body = utf8.decode(response.bodyBytes);
    print("ApiService: GET /$endpoint received ${body}");
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(body)['data']);
    } else {
      throw Exception('Failed to load data: ${body}');
    }
  }

  Future<T> post<T>(String endpoint, {Map<String, dynamic>? requestBody, Map<String, String>? headers, required T Function(dynamic) fromJson}) async {
    print("ApiService: POST to /$endpoint with body=$requestBody");
    headers = {
      'Content-Type' : 'application/json',
      ...?headers
    };
    final response = await http.post(
      Uri.parse('$BASE_URL/$endpoint'),
      headers: headers,
      body: requestBody != null ? jsonEncode(requestBody) : null,
    );
    String decodedBody = utf8.decode(response.bodyBytes);
    print("ApiService: POST /$endpoint received $decodedBody");
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(decodedBody)['data']);
    } else {
      throw Exception('Failed to post data: $decodedBody');
    }
  }
}
