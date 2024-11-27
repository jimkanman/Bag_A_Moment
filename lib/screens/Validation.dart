import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bag_a_moment/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ValidationScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String postalCode;
  final String description;
  final String backpackPrice;
  final String carrierPrice;
  final String miscellaneousPrice;
  final String? openTime;
  final String? closeTime;
  final File? image;
  final String refundPolicy; //환불정책 string?
  final File? file;
  final List<String> storageOptions;


  const ValidationScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    required this.postalCode,
    required this.description,
    required this.backpackPrice,
    required this.carrierPrice,
    required this.miscellaneousPrice,

    this.openTime,
    this.closeTime,
    this.image,
    required this.refundPolicy,
    this.storageOptions = const [], // 기본값 추가
    this.file,

  }) : super(key: key);

  //시간 변환 함수
  String _timeOfDayToString(String? time) {
    if (time == null) return "00:00"; // 기본값 설정
    try {
      final TimeOfDay parsedTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]),
      );
      final hour = parsedTime.hour.toString().padLeft(2, '0');
      final minute = parsedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return "00:00"; // 파싱 실패 시 기본값 반환
    }
  }


  Future<void> _submitData(BuildContext context) async {
    // openingTime과 closingTime 필수 검사
    if (openTime == null || closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운영 시간을 입력해주세요.')),
      );
      return; // 종료
    }

    final String url = 'http://3.35.175.114:8080/storages'; // 서버 API 주소




    try {
      // Flutter Secure Storage에서 토큰 읽기
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }
      // Multipart Request 생성
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token, // 인증 토큰 추가
      });



      // 헤더 출력 (디버깅)
      final headers = {
        'Authorization': token,
      };
      print('Request Headers: $headers');
      print('Request Body: ${request}');

      // 본문 데이터 추가
      request.fields.addAll({
        "registerName": name,
        "phoneNumber": phone,
        "description": description,
        "postalCode": postalCode,
        "detailedAddress": address,
        "openingTime": _timeOfDayToString(openTime),
        "closingTime":  _timeOfDayToString(closeTime),
        "backpackPricePerHour": backpackPrice,
        "carrierPricePerHour": carrierPrice,
        "miscellaneousItemPricePerHour": miscellaneousPrice,
      });
      // `storageOptions` 필드를 JSON 배열로 추가
      if (storageOptions.isNotEmpty) {
        request.fields['storageOptions'] = jsonEncode(storageOptions);
      }
      print('Selected Storage Options: $storageOptions');





      // 이미지 파일 추가 (선택적으로 추가)
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image!.path),
        );
      }
      // 약관 파일 추가 (선택적으로 추가)
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath('termsAndConditions', file!.path),
        );
      }


      // POST request 보내기
      final response = await request.send();
      // 응답 확인
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['isSuccess'] == true) {
          // 응답 데이터 확인
          final data = jsonResponse['data'];

          print("Registration Successful!");
          print("ID: ${data['id']}");
          print("Name: ${data['name']}");
          print("Owner ID: ${data['ownerId']}");
          print("Phone Number: ${data['phoneNumber']}");
          print("Description: ${data['description']}");
          print("Notice: ${data['notice']}");
          print("Postal Code: ${data['postalCode']}");
          print("Address: ${data['detailedAddress']}");
          print("Latitude: ${data['latitude']}");
          print("Longitude: ${data['longitude']}");
          print("Opening Time: ${data['openingTime']}");
          print("Closing Time: ${data['closingTime']}");
          print("Backpack Price Per Hour: ${data['backpackPricePerHour']}");
          print("Carrier Price Per Hour: ${data['carrierPricePerHour']}");
          print(
              "Miscellaneous Item Price Per Hour: ${data['miscellaneousItemPricePerHour']}");
          print("Terms and Conditions: ${data['termsAndConditions']}");
          print("Images: ${data['images']}");
          print("Storage Options: ${data['storageOptions']}");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('보관소 등록이 완료되었습니다!')),
          );
          Navigator.pop(context); // 성공 시 이전 화면으로 이동

        } else { //isSuccess 가 false이면
          print('Request Failed: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('등록 실패: ${jsonResponse['message']}')),
          );
        }
      } else {
        // HTTP 상태 코드가 200이 아닐 때 처리
        try {
          final responseBody = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseBody);
          print('Server Error:');
          print('Status Code: ${response.statusCode}');
          print('Message: ${jsonResponse['message']}');
          print('Error Data: ${jsonResponse['data']}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 오류: ${jsonResponse['message']}')),
          );
        } catch (e) {
          // JSON 파싱 실패 시 처리
          final responseBody = await response.stream.bytesToString();
          print('Server Response Body: $responseBody');
          print('Failed to parse server error response. Raw response: ${responseBody}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 오류 발생: ${response.statusCode}')),
          );
        }
      }
    } catch (e, stacktrace) {
  print('Exception occurred: $e');
  print('Stacktrace: $stacktrace');
}

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          '입력 정보 확인',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
        ),
        backgroundColor: Color(0xFF4DD9C6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보관소명:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 내부 여백
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // 연한 회색 배경
                borderRadius: BorderRadius.circular(18), // 둥근 모서리
              ),
              child: Text(
                name, // 사용자가 입력한 데이터
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927), // 텍스트 색상
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '전화번호:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                phone,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927),
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '주소:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927),
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '운영 시간:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // 연한 회색 배경
                borderRadius: BorderRadius.circular(18), // 둥근 모서리
              ),
              child: Text(
                '$openTime ~ $closeTime',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927), // 텍스트 색상
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '보관소 소개:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927),
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            if (image != null)
              Text(
                '보관소 대표 이미지:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
              ),
            SizedBox(height: 10),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    image!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '가격 정보:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '가방: $backpackPrice 원',
                    style: TextStyle(fontSize: 18, color: Color(0xFF0E2927)),
                  ),
                  Text(
                    '캐리어: $carrierPrice 원',
                    style: TextStyle(fontSize: 18, color: Color(0xFF0E2927)),
                  ),
                  Text(
                    '기타 물품: $miscellaneousPrice 원',
                    style: TextStyle(fontSize: 18, color: Color(0xFF0E2927)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            Text(
              '환불 정책:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                refundPolicy,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0E2927),
                ),
              ),
            ),
            SizedBox(height: 15),
            Divider(
              color: Colors.grey, // 구분선 색상
              thickness: 1,       // 구분선 두께
              indent: 16,         // 구분선 왼쪽 여백
              endIndent: 16,      // 구분선 오른쪽 여백
            ),
            SizedBox(height: 15),
            if (file != null)
              Text(
                '약관 파일:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF31BEB0)),
              ),
            if (file != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  file!.path.split('/').last,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0E2927),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 뒤로 이동, 뒤가 입력페이지인지 확인
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      ' 뒤로 ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10, width:80 ),
                Row(
                mainAxisAlignment: MainAxisAlignment.end, // 우측 정렬
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _submitData(context); // 서버로 데이터 전송
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF31BEB0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      '   서버로 전송   ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  ],
                ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

