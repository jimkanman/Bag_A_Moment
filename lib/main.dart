import 'dart:convert';

import 'package:bag_a_moment/rounter/locations.dart';
import 'package:bag_a_moment/screens/storageManage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/screens/loading_screen.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/reservation.dart';
import 'package:bag_a_moment/screens/storage.dart';
import 'package:bag_a_moment/screens/myhome.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bag_a_moment/api_response.dart';
import 'widgets/marker_details_widget.dart';
import 'theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final FlutterSecureStorage secureStorage = FlutterSecureStorage();
String? globalToken;
String? globalUserId;

Future<void> loadStoredValues() async {
  globalToken = await secureStorage.read(key: 'auth_token');
  globalUserId = await secureStorage.read(key: 'user_id');
  print('Global Token: $globalToken');
  print('Global User ID: $globalUserId');
}


class JimApp extends StatelessWidget {
  const JimApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InitialScreen(),
      theme: ThemeData(
        //텍스트 스타일 지정
        fontFamily: "Pretendard"
        // textTheme: TextTheme(
        //   // 1. 기본 제목 서체 + 색상
        //   bodyLarge: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w400,
        //     fontSize: 16,
        //     color: Colors.black,
        //   ),
        //   bodyMedium: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w300,
        //     fontSize: 14,
        //   ),
        //   bodySmall: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w200,
        //     fontSize: 12,
        //   ),
        //   titleLarge: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w700,
        //     fontSize: 20,
        //   ),
        //   titleMedium: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w600,
        //     fontSize: 18,
        //   ),
        //   titleSmall: TextStyle(
        //     fontFamily: 'Paperlogy',
        //     fontWeight: FontWeight.w500,
        //     fontSize: 16,
        //   ),
        // ),
      ),

    );
  }
}


class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // 로딩 화면을 2초 동안 보여주기 위해 딜레이 추가
    await Future.delayed(Duration(seconds: 2));
    //sharedPreference에 저장
    try {
      //로그인 상태 받아오기
      final response = await http.post(Uri.parse('http://3.35.175.114:8080/login'));
      // 로그인 상태에 따라 페이지 네비게이션 처리
      if (response.statusCode == 200) {
        //1. 로그인 되어 있는 경우,
        //sharedPreference 저장, data JWT 저장
        print('서버 응답 OK: 상태 코드 ${response.statusCode}, 응답: ${response.body}');

        //jsonDecode로 정보 저장
        final Map<String, dynamic> responseJson = jsonDecode(response.body);

        //API_response 객체 생성
        final apiResponse = API_response.fromJson(responseJson);

        // SharedPreferences에 유저 정보 저장
        final String userId = apiResponse.data['id'];
        final String jwtToken = apiResponse.data['authorization'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('jwt_token', jwtToken);
        print('로그인 성공: ID: $userId, 토큰: $jwtToken');
        // MainBottomScreen으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainBottomScreen()),
          );

      } else { // API에서 isSuccess가 false인 경우
        print('로그인 실패: 상태 코드 ${response.statusCode}, 응답 메시지: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('짐깐만 이용을 위해 로그인 해주세요.')),
          // 추가 작업 (예: JWT 저장 및 화면 이동)
        );
      }
    } catch (e) { // 네트워크 오류 또는 JSON 파싱 오류
      print('HTTP 요청 실패: $e');
      _showLoginError();
    }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen(),
        )
      );

  }

  //로그인 실패
  void _showLoginError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('짐깐만 이용을 위해 로그인 해주세요.')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

    @override
    Widget build(BuildContext context) {
      return LoadingScreen(); // 앱을 실행할 때 처음에 로딩 화면이 표시됨
    }
  }


//모든 플러터 위젯 시작점
void main() {
  runApp(
    JimApp());
}


//하단바
class MainBottomScreen extends StatefulWidget {
  @override
  _MainScreenBottomState createState() => _MainScreenBottomState();
}

//하단 메뉴바
class _MainScreenBottomState extends State<MainBottomScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [
    HomeScreen(), // 홈 (지도 페이지)
    ReservationCheckScreen(), // 예약 내역 페이지
    StorageManagementPage(), // 내보관소 페이지
    MyPageMainScreen(), // 마이페이지
  ];
  void _onItemTapped(int index) {
    setState(() {
      print("탭 선택: $index");
      _selectedIndex = index;
    });
  }

  //하단바 위젯
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ), // 현재 선택된 페이지
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
            icon: Icon(Icons.table_rows),
            label: '내 보관소',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF21B2A6),
        unselectedItemColor: Colors.grey.shade600, // 클릭되지 않은 탭 색상 (회색)
        onTap: _onItemTapped, // 탭 변경 시 호출
      ),
    );
  }
}