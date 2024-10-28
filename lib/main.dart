import 'package:bag_a_moment/rounter/locations.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/screens/loading_screen.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';

bool isLoggedIn = false; // 로그인 상태를 나타내는 변수
//Beamer 인스턴스 전역 선언
final _routerDelegate = BeamerDelegate(
  //Beamer 가드-로그인 처리
    guards: [
      BeamGuard(
        pathPatterns: ['/home'], // 보호하려는 경로 설정: 홈화면
        check: (context, location) {
          // 로그인 여부 등 조건을 확인 (true: 항상 통과, false: 로그인 요청)
          return isLoggedIn;
        },
        showPage: BeamPage(child: AuthScreen()), // 변수 false일 때 표시할 페이지
      )
    ],
    locationBuilder: BeamerLocationBuilder(
        beamLocations: [HomeLocation()]
    )
);

//모든 플러터 위젯 시작점
void main() {
  runApp(JimApp());
}

class JimApp extends StatelessWidget {
  const JimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerParser(), //비머에게 모든 페이지 이동권한 넘김
      routerDelegate: _routerDelegate, //페이지 위임 권한, Beamer 인스턴스에게
    );
  }
/*
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>( //퓨처 빌더 위젯: 로딩-> 1. 에러 2. 메인 처리
        future: Future.delayed(Duration(seconds: 3), () => 100),
        //3초 후 빌더값은 스냅샷 불러옴
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 900), //페이드 인아웃 효과
            child: _loadingWidget(snapshot), //로딩 위젯 지정
          );
        }
    );
  }*/

  //스플래쉬 로딩 위젯 선언(인스턴스)
  Widget _loadingWidget(AsyncSnapshot<Object> snapshot) {
    if (snapshot.hasError) {
      print('로딩 중 에러가 발생하였습니다.');
      return Text('Error');
    }
    else if (snapshot.hasData) {
      return HomeScreen();
    } //에러 없으면 home_screen으로 넘어감
    else {
      return loadingScreen();
    }
  }
}






