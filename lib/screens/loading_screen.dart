import 'package:extended_image/extended_image.dart';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              ExtendedImage.asset('assets/images/mainLogo.png',
                  fit: BoxFit.cover
              ),
              SizedBox(height: 20), //이미지, 로딩바 사이 간격
              CircularProgressIndicator( //로딩
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // 로딩바 색상 지정
              ),
            ],
          ),
        ),
    );
  }
}
