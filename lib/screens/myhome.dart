import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bag_a_moment/screens/mypage.dart'; // 회원 정보 조회 페이지
import 'package:bag_a_moment/userInfo.dart';

class MyPageMainScreen extends StatefulWidget {
  @override
  _MyPageMainScreenState createState() => _MyPageMainScreenState();
}

class _MyPageMainScreenState extends State<MyPageMainScreen> {
  Map<String, dynamic>? _userData;
  Map<String, int> _volumeData = {};
  static const platform = MethodChannel("com.example.example/message");

  Future<void> _fetchVolumeData() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getVolumeAndroid');
      setState(() {
        _volumeData = {
          'width': result['width'],
          'height': result['height'],
          'depth': result['depth'],
        };
      });
    } on PlatformException catch (e) {
      print("Failed to get volume: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 사용자 데이터를 초기화 시 로드
  }

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
        backgroundColor: Color(0xffF7F8FA),
        body: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(
              top: 48,
              left: 12,
              right: 12,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: myhome_bar(),
                ),
                Flexible(
                    fit: FlexFit.loose,
                    child: userbox()
                ),
                Flexible(child: settingbox())
              ],
            )));
  }

  // 버튼 위젯 생성 함수
  Widget _buildButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF26D1BA),
          backgroundColor: Color(0xFFE0F7F5),
          minimumSize: Size(double.infinity, 50),
          // 글씨 색상
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

class myhome_bar extends StatelessWidget {
  const myhome_bar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '현재환',
                  style: TextStyle(
                    color: Color(0xFF2CB598),
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 0.05,
                    letterSpacing: -0.50,
                  ),
                ),
                TextSpan(
                  text: '님, 안녕하세요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 0.05,
                    letterSpacing: -0.50,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 8),
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: FlutterLogo(),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: FlutterLogo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class userbox extends StatelessWidget {
  const userbox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Color(0xFFDDE0E4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

