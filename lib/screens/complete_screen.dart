//예약 완료 화면
//TODO: 다른 파일로 분리할 것
import 'package:bag_a_moment/screens/reservation/reservationRequestScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompleteScreen extends StatelessWidget {
  final onPreesed;
  final String title;
  CompleteScreen({ this.onPreesed, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECFFFA), // #ECFFFA 색상 설정
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/check-circle-broken.png',
              height: 150, // 이미지 크기 설정
              width: 150,
            ),
            Text('성공적으로 완료되었습니다.'),
            SizedBox(height: 20), // 이미지와 버튼 사이 간격
            ElevatedButton(
              onPressed: onPreesed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // 버튼 배경색
                foregroundColor: Colors.white, // 버튼 텍스트 색
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                title+"로 가기",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
