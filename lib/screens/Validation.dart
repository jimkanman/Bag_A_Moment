import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _submitData(BuildContext context) async {

    final String url = 'http://3.35.175.114:8080/storages'; // 서버 API 주소

    String _formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }


    try {
      // multipart 요청 생성
      var request = http.MultipartRequest('POST', Uri.parse(url));


      final Map<String, dynamic> requestBody = {
        "registerName": name,
        "phoneNumber": phone,
        "description": description,
        "postalCode": "00000", // Replace with actual postal code if needed
        "detailedAddress": address,
        "openingTime": _formatTime(openTime! as TimeOfDay), // 예: "07:30"
        "closingTime": _formatTime(closeTime! as TimeOfDay), // 예: "12:50"

        "backpackPricePerHour": int.tryParse(backpackPrice), // Assuming price is numeric
        "carrierPricePerHour": int.tryParse(carrierPrice), // Same price for all item types
        "miscellaneousItemPricePerHour": int.tryParse(miscellaneousPrice),
        "termsAndConditions": refundPolicy,
        "storageImages": image != null
            ? ["data:image/jpeg;base64,${base64Encode(await image!.readAsBytes())}"]
            : [],

        "storageOptions": storageOptions,
      };
      print('Request Body: ${requestBody}');
      print('Request Body: ${jsonEncode(requestBody)}');



      // 이미지 파일 추가 (선택적으로 추가)
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image!.path),
        );
      }

      // 약관 파일 추가 (선택적으로 추가)
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath('termsFile', file!.path),
        );
      }

      // POST request 보내기
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      // 응답 확인
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('보관소 등록이 완료되었습니다!')),
          );
          Navigator.pop(context); // 성공 시 이전 화면으로 이동
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('등록 실패: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('입력 정보 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('보관소명: $name', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('전화번호: $phone', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('주소: $address', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('운영 시간: $openTime ~ $closeTime', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('보관소 소개: $description', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (image != null) Image.file(image!, height: 100, width: 100),
            SizedBox(height: 30),
            Text('가방 가격: $backpackPrice 원', style: TextStyle(fontSize: 16)),
            Text('캐리어 가격: $carrierPrice 원', style: TextStyle(fontSize: 16)),
            Text('기타 물품 가격: $miscellaneousPrice 원', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('환불 정책: $refundPolicy', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (file != null) Text('약관 파일: ${file!.path.split('/').last}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitData(context); // 서버로 데이터 전송
              },
              child: Text('서버로 전송'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 뒤로 이동
              },
              child: Text('뒤로'),
            ),
          ],
        ),
      ),
    );
  }
}
