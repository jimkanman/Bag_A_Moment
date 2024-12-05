// import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//로딩 스크린 클래스 생성
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          // 전체 화면을 채우는 이미지
          // Positioned.fill(
          //   child: ExtendedImage.asset(
          //     'assets/images/main.png',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          // 이미지 위에 중하단에 위치한 로딩 인디케이터
          Align(
            alignment: Alignment(0.0, 0.7), // 수직 위치 조정 (1.0이 가장 아래)
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB3EDE5)),
            ),
          ),
        ],
      ),
    );
  }
}