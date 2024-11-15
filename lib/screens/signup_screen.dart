import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isPasswordMatching = true;

  //회원가입
  Future<void> _signup() async {
    final response = await http.post(
      Uri.parse('http://3.35.175.114:8080/signup'),
      headers: {
        'Content-Type': 'application/json',
        // Content-Type을 JSON 형식으로 설정함
      },
      body: jsonEncode({
        'loginId': _idController.text,
        'password': _passwordController.text, //password는 비밀번호 일치할때만 보내므로 1개만 post했음
        'nickname': _nicknameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
      }),
    );


    if (response.statusCode == 200) {
      //회원가입 성공
      print("회원가입 성공: ${response.statusCode} ${response.body}");
      // 회원가입 성공 시 로그인 화면으로 돌아감
      _showSucessful();
    } else {
      // 서버 오류 메시지 표시
      print('회원가입 실패: ${response.statusCode} ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입에 실패하였습니다. 다시 시도해주세요')),
      );
    }
  }

  // 이메일 유효성 검사 함수
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // 모든 필드가 입력되었는지 확인하는 함수
  void _checkFields() {
    String missingField = '';

    if (_idController.text.isEmpty) {
      missingField = '아이디';
    } else if (_passwordController.text.isEmpty) {
      missingField = '비밀번호';
    } else if (_confirmPasswordController.text.isEmpty) {
      missingField = '비밀번호 확인';
    } else if (_nicknameController.text.isEmpty) {
      missingField = '닉네임';
    } else if (_usernameController.text.isEmpty) {
      missingField = '실명';
    } else if (_emailController.text.isEmpty || !_isEmailValid(_emailController.text)) {
      missingField = '유효한 이메일';
    } else if (_phoneNumberController.text.isEmpty) {
      missingField = '휴대폰 번호';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      missingField = '비밀번호가 일치하지 않습니다';
    }

    if (missingField.isNotEmpty) {
      _showErrorDialog(missingField);
    } else {
      _signup();
    }
  }

  // 에러 다이얼로그 표시 함수
  void _showErrorDialog(String field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('입력 오류'),
        content: Text('$field 항목이 입력되지 않았습니다!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  // 중복 확인 버튼 클릭 시 처리 함수
  void _checkDuplicateId() {
    // 서버와 통신하여 ID 중복 확인을 수행하는 예제입니다.
    // 실제 구현 시 서버와 연동해야 합니다.
    print('아이디 중복 확인 요청');
  }
  // 회원가입 성공 팝업
  void _showSucessful() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('회원가입 성공!'),
        content: Text('짐깐만 회원이 되신 것을 환영합니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              Navigator.pop(context); // 로그인 화면으로 돌아가기
            },
            child: Text('로그인하러 가기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '아이디',
                suffix: ElevatedButton(
                  onPressed: () {
                    print('아이디 중복 확인');
                    _checkDuplicateId();
                  },
                  child: Text('중복 확인'),
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                errorText: _isPasswordMatching ? null : '비밀번호가 일치하지 않습니다.',
              ),
              onChanged: (value) {
                setState(() {
                  _isPasswordMatching = _passwordController.text == value;
                });
              },
            ),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '실명'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: '휴대폰 번호'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkFields,
              child: Text('회원가입 완료하기'),
            ),
          ],
        ),
      ),
    );
  }
}
