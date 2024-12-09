import 'package:bag_a_moment/main.dart';
import 'package:bag_a_moment/models/storage_model.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/screens/addStorage.dart';
import 'package:bag_a_moment/screens/storage.dart';
import 'package:bag_a_moment/screens/registerStorage.dart';
import 'package:bag_a_moment/services/api_service.dart';
import 'package:bag_a_moment/widgets/reservation_card_for_storage_manage_screen.dart';
import 'package:bag_a_moment/widgets/storage_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'detailed_page.dart';

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


    setState(() {
      isStorageLoading = false; // 보관소 로딩바 제거
    });
  }

  /// 최근 예약 API 호출
  Future<void> fetchRecentReservations() async {

    // TODO 예약 fetch 후 마감된 예약은 필터링


    setState(() {
      isReservationLoading = false; // 예약 로딩바 제거
    });
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

    // ApiService 초기화
    _apiService = ApiService(defaultHeader: {'Authorization' : jwt ?? ''});
  }

  Future<void> fillDummyData() async {
    storages = List.generate(3, (index) => StorageModel(), growable: true);
    reservations = List.generate(3, (index) => StorageReservation());
  }

  /// API로 나의 보관소 & 최근 예약 호출
  Future<void> fetchApiData() async {
    // TODO 양쪽 API 호출은 비동기로 변경 (동시에 하도록)
    await initialize(); // jwt & apiService 시작
    await fetchMyStorages(); // 나의 보관소 호출
    await fetchRecentReservations(); // 최근 예약 호출
    await fillDummyData();
  }

  @override
  void initState() {
    super.initState();
    fetchApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 버튼
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // 나의 보관소 섹션
          // 섹션 타이틀 ('니의 보관소' [+])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('나의 보관소', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    // TODO 라우팅 검토 (추가 정보 없이 StorageScreen으로 가면 안될 거 같지??)
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StorageScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StorageCard(),
          StorageCard(),
          StorageCard(),

          // 보관소 리스트
          // for(int index = 0; index < storages.length; index++)
          //   StorageCard(),

          // 최근 예약 섹션
          const SizedBox(height: 16,),
          const Text('최근 예약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
          const SizedBox(height: 16),

          // 예약 리스트
          for(var reservation in reservations)
            ReservationManageCard(),
          // for(var reservation in reservations)
          //   ReservationManageCard(),
        ],
      ),
    );
  }
}
