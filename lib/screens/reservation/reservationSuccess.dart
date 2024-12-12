//예약 완료 화면
//TODO: 다른 파일로 분리할 것
import 'package:bag_a_moment/screens/reservation/reservationRequestScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ReservationsuccessPage extends StatelessWidget {
  final Map<String, dynamic> info;
  ReservationsuccessPage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECFFFA), // #ECFFFA 색상 설정
      appBar: AppBar(
        title: Text(info['name'] ?? '결제 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/check-circle-broken.png', // 이미지를 넣을 경로
              //이미지가 안나옴
              height: 150, // 이미지 크기 설정
              width: 150,
            ),
            Text('예약이 성공적으로 완료되었습니다.'),
            SizedBox(height: 20), // 이미지와 버튼 사이 간격
            ElevatedButton(
              onPressed: () {
                final mainScreenState = mainScreenKey.currentState; // GlobalKey로 상태 접근
                mainScreenState?.navigateTo(1);

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // 버튼 배경색
                foregroundColor: Colors.white, // 버튼 텍스트 색
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                '예약 관리로 돌아가기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
