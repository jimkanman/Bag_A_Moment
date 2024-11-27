import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//해당 유저가 건 예약을 확인하는 페이지. 아직 구현x

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


      final String url = 'http://3.35.175.114:8080/reservations/1'; // 서버 API

      // 요청 헤더에 토큰 추가
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'accept': 'application/json',
        },
      );
      print("HTTP 응답 상태 코드: ${response.statusCode}");


      try {
        final response = await http.get(Uri.parse(url));
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          if (jsonResponse['isSuccess'] == true) {
            setState(() {
              final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
              final reservations = jsonResponse['data'];
              print('jsonResponse isSuccess:${jsonResponse['isSuccess']}');
              print('jsonResponse code:${jsonResponse['code']}');
              print('jsonResponse Message: ${jsonResponse['message']}');
              print(
                  'jsonResponse Body Data ${jsonResponse['data']}'); // 모든 보관소 정보 다 담겨서 오는  곳 이거!

              _reservations = List<Map<String, dynamic>>.from(reservations);
              _isLoading = false;
            });
          } else {
            print("서버에서 실패 응답을 보냈습니다: ${jsonResponse['message']}");
            throw Exception('Failed to fetch reservations');
          }
        } else {
          print("HTTP 상태 코드 에러: ${response.statusCode}");
          print("응답 본문: ${response.body}");
          print('jsonResponse Message: ${jsonResponse['message']}');
          throw Exception('Server error');
        }
      } catch (e) {
        print('Error fetching reservations: $e');
        setState(() {
          _isLoading = false;
        });
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
        title: Text('나의 예약'),
        backgroundColor: Color(0xFF4DD9C6),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          final remainingTime = DateTime.parse(reservation['end_date'])
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
                        errorBuilder: (context, error, stackTrace) =>
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          backgroundColor: remainingTime.isNegative
                              ? Colors.red
                              : Colors.green,
                        ),
                        child: Text(
                            remainingTime.isNegative ? '연체 처리' : '추가 요청'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
