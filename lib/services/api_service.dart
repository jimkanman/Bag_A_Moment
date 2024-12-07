import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _BASE_URL = "http://3.35.175.114:8080";
  Map<String, String>? _defaultHeader;


  ApiService({Map<String, String>? defaultHeader}):
        _defaultHeader = defaultHeader;

  Future<T> get<T>(String endpoint, {Map<String, String>? headers, required T Function(dynamic) fromJson}) async {
    print("ApiService: GET to '$_BASE_URL/$endpoint");
    headers = {
      'Content-Type' : 'application/json',
      ...?_defaultHeader,
      ...?headers
    };
    final response = await http.get(Uri.parse('$_BASE_URL/$endpoint'), headers: headers);
    String body = utf8.decode(response.bodyBytes);
    print("ApiService: GET /$endpoint received ${body}");
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(body)['data']);
    } else {
      throw Exception('Failed to load data: ${body}');
    }
  }

  /// 주어진 파라미터로 POST 전송 + data 필드에 fromJson 매핑하여 반환
  Future<T> post<T>(String endpoint, {Map<String, dynamic>? requestBody, Map<String, String>? headers, required T Function(dynamic) fromJson}) async {
    print("ApiService: POST to '$_BASE_URL/$endpoint' with body=$requestBody");
    headers = {
      'Content-Type' : 'application/json',
      ...?_defaultHeader,
      ...?headers
    };
    final response = await http.post(
      Uri.parse('$_BASE_URL/$endpoint'),
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

  /// 주어진 파라미터로 POST 전송 (multipart/form-data 지원) + fromJson 매핑하여 반환
  Future<T> postMultipart<T>(
      String endpoint, {
        Map<String, String>? fields, // 일반 폼 데이터
        Map<String, String>? headers, // 추가 헤더
        List<http.MultipartFile>? files, // 업로드할 파일 리스트
        required T Function(dynamic) fromJson, // JSON 매핑 함수
      }) async {
    print("ApiService: POST (multipart) to '$_BASE_URL/$endpoint' with fields=$fields and files=${files?.length}");

    // 기본 헤더 설정
    headers = {
      ...?_defaultHeader,
      ...?headers,
    };

    // Multipart Request 생성
    final request = http.MultipartRequest('POST', Uri.parse('$_BASE_URL/$endpoint'));
    request.headers.addAll(headers);

    // 일반 폼 데이터 추가
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // 파일 추가
    if (files != null) {
      request.files.addAll(files);
    }

    // 요청 보내기
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // 응답 처리
    String decodedBody = utf8.decode(response.bodyBytes);
    print("ApiService: POST (multipart) /$endpoint received $decodedBody");

    if (response.statusCode == 200) {
      return fromJson(jsonDecode(decodedBody)['data']);
    } else {
      throw Exception('Failed to post multipart data: $decodedBody');
    }
  }
}
