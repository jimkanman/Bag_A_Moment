import 'package:flutter/material.dart';

//비머 가드 false 리턴화면
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
        body: Center( // Center 위젯으로 텍스트를 화면 중앙에 배치
          child: Text(
        '로그인 해주세요',
        style: TextStyle(fontSize: 24, color: Colors.white), // 텍스트 스타일 추가
          ),
        ),
    );
  }
}