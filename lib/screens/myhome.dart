import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bag_a_moment/screens/mypage.dart'; // 회원 정보 조회 페이지
import 'package:bag_a_moment/userInfo.dart';


class MyPageMainScreen extends StatefulWidget {
  @override
  _MyPageMainScreenState createState() =>  _MyPageMainScreenState();
}


class _MyPageMainScreenState extends State<MyPageMainScreen> {
  Map<String, dynamic>? _userData;

  Future<void> _loadUserData() async {
    final userData = await Userinfo.fetchUserData();
    if (userData != null) {
      setState(() {
        _userData = userData;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 가져올 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("마이페이지"),
        backgroundColor: Colors.teal, // 앱바 색상
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // 배경 이미지 경로
            fit: BoxFit.cover, // 화면에 맞게 이미지 크기 조정
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.teal, // 닉네임 배경 색상
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('닉네임: ${_userData!['nickname']}', style: TextStyle(fontSize: 16)),
                  Text(
                    "OO님,",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "짐깐만요!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1.0,
              height: 20,
              color: Color(0xFFE0F7F5),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildButton(
                    context,
                    "회원 정보 조회 하기",
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPage()),
                    ),
                  ),
                  _buildButton(context, "그동안 맡긴 기록 확인하기", () {
                    // TODO: 기록 확인 페이지로 이동
                  }),
                  _buildButton(context, "짐 크기 확인하기", () {
                    // TODO: 짐 크기 확인 페이지로 이동
                  }),
                  _buildButton(context, "결제 수단 등록", () {
                    // TODO: 결제 수단 등록 페이지로 이동
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 위젯 생성 함수
  Widget _buildButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF26D1BA), backgroundColor: Color(0xFFE0F7F5), minimumSize: Size(double.infinity, 50), // 글씨 색상
          side: BorderSide(color: Colors.white, width: 1.5), // 테두리
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
