import 'package:bag_a_moment/rounter/locations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/screens/loading_screen.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/reservation.dart';
import 'package:bag_a_moment/screens/storage.dart';
import 'package:bag_a_moment/screens/mypage.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


class JimApp extends StatelessWidget {
  const JimApp({Key? key}) : super(key: key);

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_data') != null;

    //토큰 해독해서 현재 시간 비교, 만료확인
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: LoadingScreen(),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: 로딩 중 문제가 발생했습니다.'),
              ),
            ),
          );
        } else {
          bool isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: isLoggedIn ? MainScreen() : LoginScreen(),
          );
        }
      },
    );
  }
}

//모든 플러터 위젯 시작점
void main() {
  runApp(JimApp());
}


