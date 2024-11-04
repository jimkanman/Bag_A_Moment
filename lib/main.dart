import 'package:bag_a_moment/rounter/locations.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/screens/loading_screen.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/reservation.dart';
import 'package:bag_a_moment/screens/storage.dart';
import 'package:bag_a_moment/screens/mypage.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';
import 'theme.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 페이지 목록 정의
  final List<Widget> _pages = [
    HomeScreen(), // 홈 (지도 페이지)
    ReservationScreen(), // 예약 내역 페이지
    StorageScreen(), // 내보관소 페이지
    ProfileScreen(), // 마이페이지
  ];

  // 탭 선택 시 호출되는 메서드
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 현재 선택된 페이지
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '예약',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: '내 보관소',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // 탭 변경 시 호출
      ),
    );
  }
}


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
              return MaterialApp(
                home: LoadingScreen(),
              );
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우 에러 화면 표시
              return Scaffold(
                body: Center(
                  child: Text('Error: 로딩 중 문제가 발생했습니다.'),
                ),
              );
            } else {
              // 로딩 완료 후 MainScreen 표시
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: appTheme, // theme.dart에서 가져온 테마 사용
                home: MainScreen(), // MainScreen을 초기 화면으로 설정
              );
            }
            // 초기 경로를 '/home'으로 설정하여 BeamGuard가 적용되도록 함
          },
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


