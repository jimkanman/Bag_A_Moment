import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 서버에서 예약 데이터를 가져오는 함수
  Future<void> _fetchReservations() async {
    try {
      final token = await _storage.read(key: 'auth_token'); // 로그인 토큰 읽기
      if (token == null) {
        print("로그인 토큰이 없습니다.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      final String url = 'http://3.35.175.114:8080/reservations/2';

      // 요청 헤더에 토큰 추가
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'accept': 'application/json',
        },
      );
      print("HTTP 응답 상태 코드: ${response.statusCode}");


      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          setState(() {
            _reservations = List<Map<String, dynamic>>.from(jsonResponse['data']);
            print("#######################");
            print("서버 응답 data: ${_reservations}");
            _isLoading = false;
          });
        } else {
          print("서버에서 실패 응답을 보냈습니다: ${jsonResponse['message']}");
          throw Exception('Failed to fetch reservations');
        }
      } else {
        print("HTTP 상태 코드 에러: ${response.statusCode}");
        print("응답 본문: ${response.body}");
        throw Exception('Server error');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 예약 상태에 따른 색상 반환
  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green.shade100;
      case 'PENDING':
        return Colors.yellow.shade100;
      case 'REJECTED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReservations(); // 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나의 예약',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4DD9C6), // 민트색
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print("새로고침 버튼 클릭됨."); // 디버깅: 새로고침 버튼 로그
              _fetchReservations(); // 예약 데이터 다시 가져오기
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 예약 개수 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Text(
                  '${_reservations.length}',
                  style: TextStyle(
                    fontSize: 48, // 숫자를 크게
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4DD9C6), // 민트색
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '개의 보관중인 짐이 있어요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
            Divider(
              color: Colors.grey.shade400, // 옅은 회색
              thickness: 1, // 선의 두께
              height: 20, // 위아래 간격
              indent: 16, // 왼쪽 여백
              endIndent: 16, // 오른쪽 여백
            ),

          // 예약 리스트 표시
          Expanded(
              child: _reservations.isEmpty
                      ? Center(
                    child: Text(
                      '현재 예약된 짐이 없습니다.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  final remainingTime = DateTime.parse(
                      reservation['end_date'])
                      .difference(DateTime.now());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservation['status']),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  reservation['previewImagePath'] ?? '',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error,
                                      stackTrace) =>
                                      Icon(Icons.image),
                                ),
                                SizedBox(width: 16),
                              Text(
                                '보관소 ${reservation['storage_id']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                remainingTime.isNegative
                                    ? '초과 시간: ${remainingTime.inHours.abs()}:${(remainingTime.inMinutes.abs() % 60).toString().padLeft(2, '0')}'
                                    : '남은 시간: ${remainingTime.inHours}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: remainingTime.isNegative
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                // 추가 작업 처리
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                remainingTime.isNegative
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              child: Text(remainingTime.isNegative
                                  ? '연체 처리'
                                  : '추가 요청'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
