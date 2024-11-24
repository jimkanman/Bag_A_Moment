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
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID 입력'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            TextButton(
              onPressed:() {
                Navigator.push( context, MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  },
  child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
