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

  //하단바 위젯
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
        selectedItemColor: Color(0xFF21B2A6),
        onTap: _onItemTapped, // 탭 변경 시 호출
      ),
    );
  }
}


bool isLoggedIn = true; // 로그인 상태를 나타내는 변수

final _routerDelegate = BeamerDelegate(
  initialPath: '/home', // 초기 경로 설정
  guards: [
    BeamGuard(
      pathPatterns: ['/home'], // '/home' 접근 시만 검사를 적용
      check: (context, location) {
        print("로그인 상태: $isLoggedIn");
        return isLoggedIn; // 로그인 상태 확인
      },
      showPage: BeamPage(child: AuthScreen()), // false일 때 보여줄 페이지
    ),
  ],
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(), // '/home' 경로
      AuthLocation(), // '/auth' 경로
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
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: appTheme,
                routeInformationProvider: PlatformRouteInformationProvider(
                  initialRouteInformation: RouteInformation(
                    location: isLoggedIn ? '/home' : '/auth',
                  ),
                ),
                routerDelegate: _routerDelegate,
                routeInformationParser: BeamerParser(),
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


