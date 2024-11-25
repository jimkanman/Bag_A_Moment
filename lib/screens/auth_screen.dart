import 'dart:convert';
import 'package:bag_a_moment/main.dart';
import 'package:bag_a_moment/screens/home_screen.dart';
import 'package:bag_a_moment/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // 비밀번호 보기 상태 관리 변수

  //로그인
  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://3.35.175.114:8080/login'),
      body: jsonEncode({
        'loginId': _idController.text,
        'password': _passwordController.text,

      }),
    );

    print("${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      // 로그인 성공(e.g., navigate to home screen, save JWT)
      print('로그인 성공: 상태 코드 ${response.statusCode}, 응답 메시지: ${response.body}');
      //jwt 저장, 화면 이동
      final jsonResponse = jsonDecode(response.body);
      // 'data' 객체 안에서 'authorization' 필드의 토큰 값 가져오기
      final token = jsonResponse['data']['authorization']; // API 응답에서 토큰 가져오기
      // 토큰 로컬 저장
      if (token == null) {
        print('Token is null! 응답 데이터를 확인하세요.');
        return;
      }
      await secureStorage.write(key: 'auth_token', value: ' $token');
      // 디버깅 메시지 출력
      print('Token 저장 완료: key: auth_token, value: $token');
      // 로그인 성공 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공!')),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', response.body);
      // 로그인 성공 시 홈 화면으로 이동하고 이전 경로 제거
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => MainBottomScreen()),
    (Route<dynamic> route) => false, // 모든 이전 경로 제거
    );
    } else {
      // 에러
      print('로그인 실패: 상태 코드 ${response.statusCode}, 응답 메시지: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패하였습니다. 다시 시도해주세요')),
      );
    }
  }

  Future<void> checkAuthentication() async {
    final token = await secureStorage.read(key: 'auth_token');

    if (token != null) {
      // 토큰 유효성 검증 API 호출
      final response = await http.get(
        Uri.parse('http://3.35.175.114:8080/login'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        // 토큰이 유효하면 홈 화면으로 이동
        // 로그인 성공 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // 토큰이 유효하지 않으면 로그인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // 토큰이 없으면 로그인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/login');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인',
        style: TextStyle(
          color: Color(0xFFE0F7F5),
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Color(0xFF49E0C0), actions: [
        ],
      ),
      body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage('assets/images/background.png'), // 배경 이미지 경로
              fit: BoxFit.cover, // 화면에 맞게 이미지 크기 조정
              ),
            ),
          ),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/mainLogo.png',
                height: 100,
              ),
              SizedBox(height: 40),

              SizedBox(
                  width: 300,
                  height: 100,
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                        labelText: 'ID 입력',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide.none,
                        ),
                      labelStyle: TextStyle(
                          color: Color(0xFFE0F7F5),
                          fontWeight: FontWeight.bold,
                        ),
                      filled: true,
                      fillColor: Color(0xFF80E3D6),
                    ),
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C4944)), // 텍스트 스타일
                  ),

              ),
              SizedBox(
                width: 300,
                height: 100,
                child: TextField(
                  obscureText: !_isPasswordVisible, // 비밀번호 가림 처리
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: Color(0xFFE0F7F5),
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Color(0xFF80E3D6),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // 상태 변경
                        });
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: 16, color: Color(0xFF0C4944)), // 텍스트 스타일

                ),
              ),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80E3D6),
                  foregroundColor: Color(0xFFE0F7F5),
                  elevation: 5,
                ),
                child: Text('로그인',
                  style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed:() {
                  Navigator.push( context, MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80E3D6),
                  foregroundColor: Color(0xFFE0F7F5),
                  elevation: 5,
                ),
                  child: Text('회원가입',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ],
      ),
    );
  }
}
