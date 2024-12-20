import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/main.dart';
import 'package:bag_a_moment/models/storage_model.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/screens/storage/registerStorageScreen.dart';
import 'package:bag_a_moment/services/api_service.dart';
import 'package:bag_a_moment/widgets/reservation_card_for_storage_manage_screen.dart';
import 'package:bag_a_moment/widgets/storage_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home/afterMarker/StorageDetailPage.dart';

class StorageManagementPage extends StatefulWidget {
  const StorageManagementPage({super.key});

  @override
  State<StorageManagementPage> createState() => _StorageManagementPageState();
}

class _StorageManagementPageState extends State<StorageManagementPage> {
  late ApiService _apiService;
  late final int userId;
  late final String? jwt;

  late List<StorageModel> storages;
  late List<StorageReservation> reservations;

  bool isStorageLoading = true;
  bool isReservationLoading = true;

  /// 보관소 API 호출
  Future<void> fetchMyStorages() async {

    print("fetchMyStorages 호출");
    storages=await _apiService.get("users/${userId}/storages", fromJson:
      (json) => (json as List).map((item) => StorageModel.fromJson(item)).toList());
    if(storages==null){
      print("보관소가 없습니다.");
    }
    setState(() {
      isStorageLoading = false; // 보관소 로딩바 제거
    });
  }

  /// 최근 예약 API 호출
  Future<void> fetchRecentReservations() async {

    try {
      List<StorageReservation> allReservations = [];
      for (var storage in storages) {
        try {
          print("storage ${storage.id}의 예약을 불러옵니다.");
          final storageReservations = await _apiService.get(
            "storages/${storage.id}/reservations",
            fromJson: (json) => (json as List<dynamic>)
                .map((item) => StorageReservation.fromJson(item))
                .toList(),
          );
          print(storageReservations);
          allReservations.addAll(storageReservations);
        } catch (e) {
          if (e.toString().contains('404')) {
            print("Storage ${storage.id}에는 예약이 없습니다. 빈 리스트를 추가합니다.");
            // 예약이 없으면 아무 작업도 하지 않거나 빈 리스트를 추가 (사실상 필요 없음)
          } else {
            print("Storage ${storage.id}에서 예상치 못한 오류 발생: $e");
            // 예외가 발생했지만 다음 스토리지로 넘어갑니다.
          }
        }
      }

      setState(() {
        reservations = allReservations;
        isReservationLoading = false; // 로딩 상태 해제
      });

      print("총 예약 수: ${reservations.length}");
    } catch (e) {
      print("Error while fetching reservations: $e");
      setState(() {
        isReservationLoading = false;
      });
    }
  }

  Future<void> initialize() async {
    // 로그인 처리
    jwt = await secureStorage.read(key: 'auth_token');
    String? userIdString = await secureStorage.read(key: 'user_id');
    if (jwt == null) {
      print("로그인 토큰이 없습니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }
    userId = int.parse(userIdString ?? "");
    print("initialized 호출");
    // ApiService 초기화
    _apiService = ApiService(defaultHeader: {'Authorization' : jwt ?? ''});
  }


  /// API로 나의 보관소 & 최근 예약 호출
  Future<void> fetchApiData() async {
    // TODO 양쪽 API 호출은 비동기로 변경 (동시에 하도록)
    await initialize(); // jwt & apiService 시작
    await fetchMyStorages(); // 나의 보관소 호출
    await fetchRecentReservations(); // 최근 예약 호출
    // await fillDummyData();
  }

  @override
  void initState() {
    super.initState();
    fetchApiData();
  }

  @override
  Widget build(BuildContext context) {
    if(isStorageLoading || isReservationLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDark,
            backgroundColor: Colors.white,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundMypage,
      appBar: AppBar(
        title: const Text(
          '내 보관소',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // 나의 보관소 섹션
          // 섹션 타이틀 ('니의 보관소' [+])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '내 ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '보관소',
                      style: TextStyle(
                        color: Color(0xFF2CB598),
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '는 ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '지금',
                      style: TextStyle(
                        color: Color(0xFF2CB598),
                        fontSize: 20,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add_box,color: AppColors.primaryDark,size: 25),
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StorageScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 보관소 리스트
          for(int index = 0; index < storages.length; index++)
            StorageCard(storage: storages[index]),

          // 최근 예약 섹션
          const SizedBox(height: 16,),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '처리중',
                  style: TextStyle(
                    color: Color(0xFF2CB598),
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '인 예약이에요',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for(var reservation in reservations)
            ReservationManageCard(reservation: reservation,),
        ],
      ),
    );
  }
}
