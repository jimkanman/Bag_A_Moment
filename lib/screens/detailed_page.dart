import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:bag_a_moment/screens/payment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'package:bag_a_moment/StorageDetailModel.dart'; //api 모델로 받아옴


// 상세 페이지
class StorageDetailPage extends StatefulWidget {
  final int storageId;

  const StorageDetailPage({Key? key, required this.storageId}) : super(key: key);

  @override
  _StorageDetailPageState createState() => _StorageDetailPageState();
}

class _StorageDetailPageState extends State<StorageDetailPage> {
//Map<String, dynamic>? storageDetail; //storageDetails 변수가 storageDetail 타입 객체로 변환 과정 잘못됨
  StorageDetail? storageDetails;

  bool isLoading = true;

@override
void initState() {
  super.initState();
  fetchStorageDetails();
}


  //final double _currentLatitude = 37.5045563; // 사용자의 현재 위도
  //final double _currentLongitude = 126.9569379; // 사용자의 현재 경도
  //사용자 현위치 _initialPosition을 기반으로 주변 보관소 위치! GET 요청 날리기
  //final String url = 'http://3.35.175.114:8080/storages/nearby?latitude=37.5045563&longitude=126.9569379&radius=10000';


Future<void> fetchStorageDetails() async {
  final url = Uri.parse('http://3.35.175.114:8080/storages/${widget.storageId}');
  final token = secureStorage.read(key: 'auth_token');
  try {
    final response = await http.get(url,
      headers: {
        'Authorization': '$token', // 토큰 추가
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        storageDetails = StorageDetail.fromJson(data['data']); // 데이터를 모델로 변환. 이 부분 잘 모르겠음
        isLoading = false;
      });
    } else {
      print('Failed to fetch storage details. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (error) {
    print('Error fetching storage details: $error');
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading
            ? Text('Loading...') // 로딩 중일 때
            : Text('Name: ${storageDetails?.name ?? 'Unknown'}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
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
                child:Text('주소: ${storageDetails?.detailedAddress ?? 'Unknown'}',

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
                    '${storageDetails?.notice ?? '정해진 시간을 지켜주세요'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                   '${storageDetails?.postalCode}'?? '새로 오픈했습니다! ',
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
                          //text
                      SizedBox(height: 8), // 각 항목 간 간격
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Color(0xFFF44336)), // 휴무 아이콘
                          SizedBox(width: 8),
                          Text(
                            '휴무일: ${storageDetails?.closingTime ?? '연중무휴'}',
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
                              '보관소 소개: ${storageDetails?.description ?? '환영합니다'}',
                              style: TextStyle(fontSize: 16, color: Colors.grey), // 동일한 크기 적용
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                ),
      )
              ],
            ),


            SizedBox(height: 16),

            // 옵션 정보
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (storageDetails?.storageOptions ?? []).map((option) {
                return Chip(
                  label: Text(
                    option, // 각 옵션을 표시
                    style: TextStyle(fontSize: 14),
                  ),
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
                      builder: (context) => ReservationScreen(info: {},
                        //???
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
                      builder: (context) => ReservationScreen(info: {},

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
              // ... (Other sections)
            ],
          ),

          ]
    ),
    ),
      )
    );
  }
}




