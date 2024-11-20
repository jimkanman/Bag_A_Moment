import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class API_response {
  final bool isSuccess;
  final int code;
  final String message;
  final Map<String, dynamic>data;

  API_response({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,

});

  // API_response 인스턴스 생성자 from JSON
  factory API_response.fromJson(Map<String, dynamic> json) {
    return API_response(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }

  // API_response 인스턴스를 다시 JSON으로 바꾸기
  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'code': code,
    'message': message,
    'data': data,
  };
}







// //decoding 방법
// Map apiMap = jsonDecode(jsonString);
// var api = ApifromJson(userMap);
// print('hi, ${api.message}!!!');

// //incoding 방법
// String json = jsonEncode(api);
