import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//로딩스크린 클래스 생성
class loadingScreen extends StatelessWidget {
  const loadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget> [
              Image.asset('assets/images/BagAmoment_main.png'),
            ],
          ),
        ),
    );
  }
}
