import 'dart:io';

import 'package:flutter/material.dart';

class ValidationRegister extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String postalCode;
  final String? openTime;
  final String? closeTime;
  final File? image;
  final bool deliveryService;
  //1차 전송받은 데이터


  const ValidationRegister({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    required this.postalCode,
    required this.deliveryService,

    this.openTime,
    this.closeTime,
    this.image,




  }) : super(key: key);



  Future<void> _submitData(BuildContext context) async {
    try {
      // 서버 전송 로직 (예제)
      await Future.delayed(Duration(seconds: 2));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 완료!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // 첫 화면으로 이동
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $error')),
      );
    }
  }

  //final data = widget.data;
  //_submitData(data);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('입력 확인')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('보관소 이름: $name'),
          Text('전화번호: $phone'),
          Text('주소: $address'),
          Text('우편번호: $postalCode'),
          Text('주소: $address'),

          ElevatedButton(
            onPressed: () => _submitData(context),
            child: Text('제출'),
          ),
        ],
      ),
    );
  }
}
