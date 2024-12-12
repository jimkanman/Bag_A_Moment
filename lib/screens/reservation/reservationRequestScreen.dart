import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/main.dart';
import 'package:bag_a_moment/models/location.dart';
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/services/api_service.dart';
import 'package:bag_a_moment/services/websocket_service.dart';
import 'package:bag_a_moment/utils/string_time_formatter.dart';
import 'package:bag_a_moment/widgets/expendable_reservation_card.dart';
import 'package:bag_a_moment/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../models/map_controller_notifier.dart';

//예약 조회 페이지
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  ReservationScreenState createState() => ReservationScreenState();


}

class ReservationScreenState extends State<ReservationScreen> {
  bool _isLoading = true;

  // 재환 추가
  late int userId;
  late List<StorageReservation> _reservations;
  late List<StorageReservation> _reservationsOnDelivery;
  late List<Location> _deliveryLocations;
  late ApiService _apiService;
  final WebSocketService _webSocketService = WebSocketService();

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

  /// 웹소켓 메시지 도착 시 해당 응답대로 delivery의 위치 업데이트
  void onWebSocketJsonResponse(Map<String, dynamic> json) {
    print("RECEIVED WEBSOCKET $json");
    int deliveryId = json['deliveryId'];
    double? lat = json['latitude'];
    double? lng = json['longitude'];
    print("DECODED WEBSOCKET TO $deliveryId, $lat, $lng");

    setState(() {
      for(var loc in _deliveryLocations){
        if (loc.deliveryId == deliveryId) {
          if(lat != null) loc.latitude = lat;
          if(lng != null) loc.longitude = lng;
          print("Websocket: updated location for deliveryId $deliveryId: lat=$lat, lng=$lng");
        }
        _moveCameraToLocation(deliveryId, lat!, lng!);
        break;
      }
    });
  }

  /// GoogleMap 카메라 이동
  void _moveCameraToLocation(int deliveryId, double lat, double lng) async {
    // 특정 Delivery ID의 카메라 이동
    LatLng newPosition = LatLng(lat, lng);
    print("MOVING CAMERA TO $lat $lng");
    context.read<MapControllerProvider>().moveCamera(deliveryId, newPosition);
  }


  /// 시작 시 API로 필요한 Data 가져옴
  Future<void> _fetchReservations() async {
    // API 요청 & 변수 초기화
    print("REQUESTING...");
    _reservations = await _apiService.get(
        "users/$userId/reservations",
        fromJson: (data) => (data as List<dynamic>)
        .map((d) => StorageReservation.fromJson(d))
        .toList()
    );
    print("GOT RESPONSE");

    print("SETTING RESERVATIONS_ON_DELIVERY");
    _reservationsOnDelivery = _reservations
      // .where((reservation) => reservation.deliveryReservation?.status == 'ON_DELIVERY').toList();
          .where((reservation) => reservation.deliveryReservation != null).toList();

    print("SETTING DELIVERY LOCATIONS");
    _deliveryLocations = _reservationsOnDelivery
        .map((r) => Location(
          deliveryId: r.deliveryReservation!.deliveryId,))
        .toList();

    // 배송 중인 예약의 경우 deliveryLocation 위치 받아오기
    for(int i = 0; i < _reservationsOnDelivery.length; i++) {
      if(_reservationsOnDelivery[i].deliveryReservation?.status.toUpperCase() != 'ON_DELIVERY') continue;
      // api로 배송 위치 가져옴
      final location = await _apiService.get(
          'delivery/${_deliveryLocations[i].deliveryId}/location',
          fromJson: (json) => Location.fromJson(json)
      );
      _deliveryLocations[i].latitude = location.latitude;
      _deliveryLocations[i].longitude = location.longitude;
    }

    // reservations에는 배송 중이 아닌 것만 담음
    _reservations = _reservations
      // .where((reservation) => reservation.deliveryReservation?.status != 'ON_DELIVERY').toList();
      .where((reservation) => reservation.deliveryReservation == null).toList();

    // Websocket 연결
    // TODO 일단 비활성화
    /*
    print("SETTING WEBSOCKET");
    for (var location in _deliveryLocations) {
      _webSocketService.subscribe(
          '/topic/delivery/${location.deliveryId}',
          (json) {
            // 메시지 도착 시
            onWebSocketJsonResponse(json);
          });
    }
     */

      print("SETTING IS_LOADING TO FALSE");
      setState(() { _isLoading = false;});
      print("IS_LOADING IS FALSE");
  }

  void OnDeliveryReservationButtonPress(int idx) {
    // TODO 예약상세 페이지로 라우팅?
  }

  void OnStorageReservationButtonPress(int idx) {
    // TODO 예약상세 페이지로 라우팅?
  }

  /// 로그인 처리, JWT 가져옴, ApiService 초기화
  Future<void> _initialize() async {
    // 로그인 처리
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      print("로그인 토큰이 없습니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    // Jwt 가져옴
    String? savedUserId = await secureStorage.read(key: 'user_id');
    userId = int.parse(savedUserId!);

    // ApiService 초기화
    _apiService = ApiService(defaultHeader: {'Authorization' : token ?? ''});
  }

  /// API 호출해서 데이터 가져옴
  Future<void> _fetchApiData() async {
    await _initialize(); // JWT 가져옴 & ApiService 초기화
    await _fetchReservations(); // API 호출해서 데이터 초기화
    // await _putDummyData(); // TODO 테스트 데이터 삽입. 배포 시 삭제
  }

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
    _fetchApiData();
  }

  @override
  void dispose() {
    print("DISPONSE RESERVATION REQUEST SCREEN");
    try{
      print("DISCONNECTING WEBSOCKET SERVICE");
      _webSocketService.disconnect();
    } catch (e) {
      print("exception while disconnecting websocket: $e");
    }
    super.dispose();
  }

  void disposeWebSocket() {
    try{
      print("DISCONNECTING WEBSOCKET SERVICE");
      _webSocketService.disconnect();
    } catch (e) {
      print("exception while disconnecting  websocket: $e");
    }
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
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print("새로고침 버튼 클릭됨."); // 디버깅: 새로고침 버튼 로그
              // _fetchReservations(); // 예약 데이터 다시 가져오기
              // _jaehwanFetchReservations();
              _fetchReservations();
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
                    '개의 배송 예약이 있어요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textGray
                    ),
                  ),
              ],
            ),

          // 배송 예약 카드 위젯
          if(_reservationsOnDelivery.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  for (int idx = 0; idx < _reservationsOnDelivery.length; idx++)
                    ExpandableReservationCard(
                      webSocketService: _webSocketService,
                      luggage: _reservationsOnDelivery[idx].luggage,
                      previewImagePath: _reservationsOnDelivery[idx].previewImagePath,
                      storageName: _reservationsOnDelivery[idx].storageName,
                      pickupTime: StringTimeFormatter.formatTime(_reservationsOnDelivery[idx].deliveryReservation?.deliveryArrivalDateTime),
                      backgroundColor: Colors.white,
                      onButtonPressed: () => OnDeliveryReservationButtonPress(idx),
                      deliveryReservation: _reservationsOnDelivery[idx].deliveryReservation!,
                      deliveryLatitude: _deliveryLocations[idx].latitude,
                      deliveryLongitude: _deliveryLocations[idx].longitude,
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
                '개의 보관 예약이 있어요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textGray
                ),
              ),
            ],
          ),

          // 보관소 예약 카드 위젯
          if(_reservations.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                children: [
                  // for (var reservation in _reservations)
                  for (int idx = 0; idx < _reservations.length; idx++)
                    ReservationCard(
                      reservation: _reservations[idx],
                      buttonBackgroundColor: AppColors.primaryDark,
                      luggage: _reservations[idx].luggage,
                      previewImagePath: _reservations[idx].previewImagePath,
                      storageName: _reservations[idx].storageName,
                      pickupTime: StringTimeFormatter.formatTime(_reservations[idx].endDateTime),
                      buttonText: const Text("연장 요청"),
                      backgroundColor: Colors.white/*determineStorageReservationCardBackgroundColor(_reservations[idx])*/,
                      onButtonPressed: () => OnStorageReservationButtonPress(idx),
                      // 다른 보관소 데이터 전달...
                    ),
                ],
              ),
            ),
      ]
      ),
    );
  }


}
