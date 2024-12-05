import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/main.dart';
import 'package:bag_a_moment/models/location.dart';
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/services/api_service.dart';
import 'package:bag_a_moment/services/websocket_service.dart';
import 'package:bag_a_moment/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<dynamic> _reservations_old = [];
  bool _isLoading = true;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 재환 추가
  late int userId;
  late List<StorageReservation> _reservations;
  late List<StorageReservation> _reservationsOnDelivery;
  late List<Location> _deliveryLocations;
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();

  // 서버에서 예약 데이터를 가져오는 함수
  /*
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['isSuccess'] == true) {
          setState(() {
            _reservations_old = List<Map<String, dynamic>>.from(jsonResponse['data']);
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
  */

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

  Future<void> _jaehwanFetchReservations() async {
    print("Fetching data");
    // 로그인 처리
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      print("로그인 토큰이 없습니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }
    String? savedUserId = await secureStorage.read(key: 'user_id');
    userId = int.parse(savedUserId!);

    // API 요청 & 변수 초기화
    print("REQEUSTING...");
    _reservations = await _apiService.get(
        "users/$userId/reservations",
        fromJson: (data) => (data as List<dynamic>)
        .map((d) => StorageReservation.fromJson(d))
        .toList()
    );
    print("GOT REPSPONSE");

    print("SETTING RESERVATIONSONDELIVERY");
    _reservationsOnDelivery = _reservations
      .where((reservation) => reservation.deliveryReservation?.status == 'ON_DELIVERY').toList();

    print("SETTING DELIVERYLOCATIONS");
    _deliveryLocations = _reservationsOnDelivery
        .map((r) => Location(
          deliveryId: r.deliveryReservation!.deliveryId,))
        .toList();

    // Websocket 연결
    print("SETTING WEBSOCKET");
    _deliveryLocations.forEach((location) {
      _webSocketService.subscribe(
          'topic/${location.deliveryId}/location',
              (json) {
            // 메시지 도착 시
            print(json);
          });
    });

      print("SETTING IS_LOADING TO FALSE");
      setState(() { _isLoading = false;});
      print("IS_LOADING IS FALSE");
  }


  Future<void> _putDummyData() async {
    print("putting data");
    // reservations, reservationOnDelivery, deliveryLocations 더미값
    _reservations = List.generate(8, (index) => StorageReservation(
        id: index,
        storageId: index,
        storageName: "보관소 $index",
        previewImagePath: AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
        luggage: const [],
        deliveryReservation: null,
        startDateTime: "2024-12-05T14:30:00",
        endDateTime: "2024-12-06T14:00:00",
        paymentAmount: 999));

    _reservationsOnDelivery = List.generate(4, (index) => StorageReservation(
      id: index,
      storageId: index,
      storageName: "보관소 $index",
      deliveryReservation: DeliveryReservation(id:index, deliveryId: index, storageId: index),
    ));

    _deliveryLocations = List.generate(4, (index) => Location(deliveryId: index));

    return;
  }

  @override
  void initState() {
    super.initState();
    // _fetchReservations(); // 데이터 가져오기
    _jaehwanFetchReservations().then((_) {
      _putDummyData(); // TODO 삭제
    });
  }

  @override
  void dispose() {
    try{
      _webSocketService.disconnect();
    } catch (e) {
      print("exception while disconnection websㅓocket: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text(
          '나의 예약',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // 민트색
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print("새로고침 버튼 클릭됨."); // 디버깅: 새로고침 버튼 로그
              // _fetchReservations(); // 예약 데이터 다시 가져오기
              _jaehwanFetchReservations();
            },
          ),
        ],
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator()) // 로딩 중
      : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if(_reservationsOnDelivery.isNotEmpty)
            Row(
              // X 개의 배송 중인 짐이 있어요!
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Text(
                    '${_reservationsOnDelivery.length}',
                    style: const TextStyle(
                      fontSize: 48, // 숫자를 크게
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // 민트색
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '개의 배송 중인 짐이 있어요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),

          // 배송 예약 카드 위젯
          /*
          ListView.builder(
            shrinkWrap: true,
            itemCount: _reservationsOnDelivery.length,
            itemBuilder: (context, index) {
              final _deliveryReservation = _reservationsOnDelivery[index];
              return ReservationCard(

                buttonBackgroundColor: AppColors.backgroundLight,
              );

          }),

           */
          if(_reservationsOnDelivery.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  for (var reservation in _reservationsOnDelivery)
                    ReservationCard(
                      buttonBackgroundColor: AppColors.backgroundLight,
                      // TODO 다른 예약 데이터 전달
                      // TODO 현재 배달 위치 확인
                    ),
                ]
              )
            ),

          const SizedBox(height: 32),

          // 보관 중인 짐 표시
          _reservations.isEmpty
          ? const Center(
              child: SizedBox(
                height: 300,
                child: Text("보관 중인 짐이 없어요!", style: TextStyle(fontSize:20, color: AppColors.textGray),)
              )
          )
          : Row (
            // X 개의 보관 중인 짐이 있어요!
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${_reservations.length}',
                style: const TextStyle(
                  fontSize: 48, // 숫자를 크게
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark, // 민트색
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '개의 보관 중인 짐이 있어요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),

          // 보관소 예약 카드 위젯
          /*
          ListView.builder(
            shrinkWrap: true,
            itemCount: _reservations.length,
            itemBuilder: (context, index) {
              final storageReservation = _reservations[index];
              return ReservationCard(
                // TODO
                buttonBackgroundColor: AppColors.backgroundLight,
              );
          }),
          */

          // 보관소 예약 카드 리스트 (for 문 사용)
          if(_reservations.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  for (var reservation in _reservations)
                    ReservationCard(
                      buttonBackgroundColor: AppColors.primaryDark,
                      // 다른 보관소 데이터 전달...
                    ),
                ],
              ),
            ),


          // TEST
          GestureDetector(
            onTap: () {
              _jaehwanFetchReservations();
            },
            child: Container(
              height: 100,
              width: 100,
              color: Colors.red,
              child: const Text("push me"),
            ),
          ),
      ]
      ),
    );
  }
}
