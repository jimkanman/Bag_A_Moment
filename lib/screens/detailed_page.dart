import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:bag_a_moment/screens/payment.dart';

import '../main.dart';


// 상세 페이지
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> markerInfo;
  DetailPage({required this.markerInfo});


  //final double _currentLatitude = 37.5045563; // 사용자의 현재 위도
  //final double _currentLongitude = 126.9569379; // 사용자의 현재 경도
  //사용자 현위치 _initialPosition을 기반으로 주변 보관소 위치! GET 요청 날리기
  //final String url = 'http://3.35.175.114:8080/storages/nearby?latitude=37.5045563&longitude=126.9569379&radius=10000';
  final token = secureStorage.read(key: 'auth_token');



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          markerInfo['name'] ?? 'Detail',
          style: TextStyle(
            color: Colors.white, // 글씨 색상을 흰색으로 설정
            fontWeight: FontWeight.bold, // 글씨를 볼드체로 설정
            fontSize: 20, // 글씨 크기를 적절히 설정 (옵션)
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4DD9C6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ),

      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 보관소 이미지
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Placeholder 색상
                borderRadius: BorderRadius.circular(8),
              ),
              child: markerInfo['image'] != null
                  ? Image.network(
                markerInfo['image'],
                fit: BoxFit.cover,
              )
                  : Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
              SizedBox(height: 20),


            //보관소 이름
            Text(
              markerInfo['name'] ?? '',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // 주소 정보
            Row(children: [
              Text(
                '주소',
                style: TextStyle(
                  fontSize:22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              SizedBox(width: 20),

              Expanded( // Text가 화면 너비를 차지하도록 제한
                child: Text(
                markerInfo['address'] ?? '주소 정보 없음',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              ),
            ],


            ),

            SizedBox(height: 20),

            Text(
              '공지사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 18),


            // 공지사항
            Container(
              width: double.infinity, // 화면 가로 크기에 맞게 확장
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    markerInfo['noticeTitle'] ?? '보관소 공지사항',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    markerInfo['noticeContent'] ?? '새로 오픈했습니다! ',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // 운영 정보: 세부 정보 표현할것
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운영 정보',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity, // 화면 가로 크기에 맞게 확장
                  padding: EdgeInsets.all(12), // 내부 여백
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // 배경색
                    borderRadius: BorderRadius.circular(8), // 둥근 모서리 처리
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.black), // 운영 시간 아이콘
                          SizedBox(width: 8), // 간격
                          Text(
                            markerInfo['hours'] ?? '운영 시간 정보 없음',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // 각 항목 간 간격
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Color(0xFFF44336)), // 휴무 아이콘
                          SizedBox(width: 8),
                          Text(
                            markerInfo['closedDays'] ?? '연중무휴',
                            style: TextStyle(fontSize: 16, color: Colors.red), // 동일한 크기 적용
                          ),
                        ],
                      ),
                      SizedBox(height: 8), // 각 항목 간 간격
                      Row(
                        children: [
                          Icon(Icons.emoji_emotions, size: 16, color: Colors.black26), // 환영 메시지 아이콘
                          SizedBox(width: 8),
                          Text(
                            markerInfo['description'] ?? '환영합니다 :)',
                            style: TextStyle(fontSize: 16, color: Colors.grey), // 동일한 크기 적용
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),


            SizedBox(height: 16),

            // 옵션 정보
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (markerInfo['options'] as List<dynamic>? ?? []).map((option) {
                return Chip(
                  label: Text(option),
                  backgroundColor: Colors.green.shade100,
                );
              }).toList(),
            ),


            SizedBox(height: 80),

          // 하단 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  print('배송 버튼 클릭');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        info: markerInfo,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB3EDE5),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('배송', style: TextStyle(color: Color(0xFF43CBBA), fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  print('보관 버튼 클릭');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        info: markerInfo,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4DD9C6),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('보관', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),



          ],
        ),
      ],
            ),
      ),
    ),
    );
  }
}



