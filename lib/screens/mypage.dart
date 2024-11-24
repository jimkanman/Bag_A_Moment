import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bag_a_moment/screens/auth_screen.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  // 서버에서 사용자 정보 가져오기
  Future<void> _fetchUserData() async {
    try {
      final token = await _storage.read(key: 'auth_token'); // 로그인 토큰 읽기
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      // 2. 토큰 디코딩하여 사용자 ID 추출
      final payload = token.split('.')[1]; // JWT 토큰의 두 번째 부분(Base64로 인코딩된 Payload)
      final normalized = base64.normalize(payload); // Base64 형식 정규화
      final decodedPayload = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decodedPayload);

      if (!payloadMap.containsKey('id')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰과 일치하는 사용자 정보가 없습니다.')),
        );
        return;
      }
      final userId = payloadMap['id']; // 사용자 ID 추출


      // 3. 서버에서 사용자 정보 요청
      final url = 'http://3.35.175.114:8080/users/$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'accept': 'application/json',
        },
      );

      // 디버깅용 로그
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonResponse['isSuccess'] == true) {
          setState(() {
            userData = jsonResponse['data']; // 사용자 데이터 저장
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원 정보 로드 실패: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원 정보 로드 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token'); // 저장된 토큰 삭제
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그아웃 되었습니다.')),
    );

    // 로그인 화면으로 이동 및 모든 이전 화면 제거
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }




  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // 로그아웃 아이콘
            onPressed: _logout, // 로그아웃 버튼 클릭 시 실행
          ),
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
          Container(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
                  : userData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '회원 정보',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: 10),
                        Text('ID: ${userData!['loginId']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('닉네임: ${userData!['nickname']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('이름: ${userData!['username']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('이메일: ${userData!['email']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('전화번호: ${userData!['phoneNumber']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // 로그아웃 또는 수정 버튼 추가할것
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('회원 정보 수정 못합니다만?')),
                            );
                          },
                          child: Text('회원정보 수정하기'),
                    ),
                  ],
                ),
              ) : Center(child: Text('회원 정보를 불러올 수 없습니다.')),
          ),
        ],
      ),
    );
  }
}
