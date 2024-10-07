import 'package:flutter/material.dart';

//홈화면 클래스 생성
class HomeScreen extends StatelessWidget{
  const HomeScreen (Key? key) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      // Scaffold로 화면 전체 레이아웃을 감싸고, 배경색을 설정
      body: Container(
        color: Color.fromARGB(255, 00, 206, 209), //홈화면 기본 색상 정하기
      ),
    );
  }
}