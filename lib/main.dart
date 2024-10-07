import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/loading_screen.dart';
import 'home_screen.dart';

//모든 플러터 위젯 시작점
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>( //퓨처 빌더 위젯: 로딩-> 1. 에러 2. 메인 처리
      future: Future.delayed(Duration(seconds:3), () => 100), //3초 후 빌더값은 스냅샷 불러옴
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 900), //페이드 인아웃 효과
          child: _loadingWidget(snapshot), //로딩 위젯 지정
        );
      }
    );
  }
  //지정 로딩위젯 선언
  StatelessWidget _loadingWidget(AsyncSnapshot<Object> snapshot) {
    if(snapshot.hasError) {print('로딩 중 에러가 발생하였습니다.'); return Text('Error');}
    else if(snapshot.hasData){return HomeScreen();}
    else{return loadingScreen();}

  }
}
//