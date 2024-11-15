import 'dart:convert';
import 'package:bag_a_moment/screens/home_screen.dart';
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', response.body);
      // 로그인 성공 시 홈 화면으로 이동하고 이전 경로 제거
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => HomeScreen()),
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

  // 회원가입 함수
  Future<void> _signUp() async {
    final response = await http.post(
      Uri.parse('http://3.35.175.114:8080/signup'),
      body: {
        'loginId': _idController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 201) {
      //회원가입 성공
    } else {
      //회원가입 에러
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
              onPressed: _signUp,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
