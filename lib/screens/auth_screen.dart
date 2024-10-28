import 'package:flutter/material.dart';

//비머 가드 false 리턴화면
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Text('로그인 해주세요 :)')
    );
  }

}