import 'package:bag_a_moment/rounter/locations.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/screens/loading_screen.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';

bool isLoggedIn = true; // 로그인 상태를 나타내는 변수
//Beamer 인스턴스 전역 선언
final _routerDelegate = BeamerDelegate(
  //Beamer 가드-로그인 처리
    guards: [
      BeamGuard(
        pathPatterns: ['/home'], // 보호하려는 경로 설정: 홈화면
        check: (context, location) {
          // 로그인 여부 등 조건을 확인 (true: 항상 통과, false: 로그인 요청)
          //return isLoggedIn;
          print("로그인 상태: $isLoggedIn");
          return isLoggedIn;
        },
        showPage: BeamPage(child: AuthScreen()), // 변수 false일 때 표시할 페이지
      ),
    ],
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(), // '/home' 경로에 대응
      AuthLocation(), // '/auth' 경로에 대응
    ],
  ),
);

class JimApp extends StatelessWidget {
  const JimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
      future: Future.delayed(Duration(seconds: 3), () => 100), // 3초 로딩 후 빌더값 반환
      builder: (context, snapshot) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routeInformationParser: BeamerParser(),
          routerDelegate: _routerDelegate,
          builder: (context, child) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 중일 때 로딩 화면 표시
              return Scaffold(
                backgroundColor: Colors.blue,
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우 에러 화면 표시
              return Scaffold(
                body: Center(
                  child: Text('Error: 로딩 중 문제가 발생했습니다.'),
                ),
              );
            } else {
              // 로딩 완료 후 실제 앱 컨텐츠 표시
              return child!;
            }
          },
        // 초기 경로를 '/home'으로 설정하여 BeamGuard가 적용되도록 함
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(
              location: isLoggedIn ? '/home' : '/auth',
            ),
          ),
        );
      },
    );
  }
}

// 홈 화면 경로 설정
class HomeLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable<dynamic> state) {
    return [
      BeamPage(
        child: HomeScreen(),
        key: ValueKey('home'),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/home'];
}

// 로그인 화면 경로 설정
class AuthLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable<dynamic> state) {
    return [
      BeamPage(
        child: AuthScreen(),
        key: ValueKey('auth'),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/auth'];
}

//모든 플러터 위젯 시작점
void main() {
  runApp(JimApp());
}


