import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/widgets/network_image_rect.dart';
import 'package:bag_a_moment/widgets/rectangular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/main.dart';

import '../../services/api_service.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final StorageReservation reservation; // 예약 정보를 저장할 변수

  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  _ReservationDetailsScreenState createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late StorageReservation reservation;
  late ApiService _apiService;
  int smallCount=0;
  int  mediumCount=0;
  int  largeCount=0;
  late final int userId;
  late final String? jwt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
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
    _apiService = ApiService(defaultHeader: {'Authorization': jwt ?? ''});
    await fetchReservation();
    print("Reservation: ${reservation.id}");
    setState(() {
      isLoading = false; // 데이터 로드 완료
    });
  }
  Future<void> processLuggageAsync() async {
    await Future.forEach(reservation.luggage, (element) async {
      // 비동기 작업이 필요한 경우 여기에 작성
      switch (element.type) {
        case 'BAG':
          smallCount++;
          break;
        case 'LUGGAGE':
          mediumCount++;
          break;
        case 'MISCELLANEOUS_ITEM':
          largeCount++;
          break;
        default:
          break;
      }
    });
  }
  fetchReservation() async {
    reservation = await _apiService.get(
      'reservations/${widget.reservation.id}',
      fromJson: (json) => StorageReservation.fromJson(json),
    );
    processLuggageAsync();
  }

  static const dummyImages = [
    'https://via.placeholder.com/150',
    AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
    'https://via.placeholder.com/150',
    AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
  ];

  submitReservationStatus(int reservation_id, String status) {
    return () async {
      await _apiService.patch(
        'reservations/$reservation_id/status?status=$status',
        fromJson: (json) => json,
      );
      //
      print('Reservation status updated to $status');
      //현재페이지 리다이렉트
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReservationDetailsScreen(reservation: reservation),
        ),
      );
    };
  }

  Widget StatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Text(
          '수락 대기',
          style: TextStyle(color: AppColors.primary),
        );
      case 'REJECTED':
        return const Text(
          '거절',
          style: TextStyle(color: AppColors.textRed),
        );
      case 'APPROVED':
        return const Text(
          '수락',
          style: TextStyle(color: AppColors.textBlue),
        );
      case 'STORING':
        return const Text(
          '보관 중',
          style: TextStyle(color: AppColors.textBlue),
        );
      case 'COMPLETE':
        return const Text(
          '완료',
          style: TextStyle(color: Colors.black),
        );
      default:
        return const Text('');
    }
  }

  Widget buildBottomButton(String status) {
    print("버튼 생성: $status");
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Row(
          children: [
            Expanded(
                child: RectangularElevatedButton(
              onPressed: submitReservationStatus(reservation.id, 'REJECTED'),
              backgroundColor: AppColors.backgroundLightRed,
              borderRadius: 8,
              child: const Text(
                "거절하기",
                style: TextStyle(color: AppColors.textRed),
              ),
            )),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: RectangularElevatedButton(
              onPressed: submitReservationStatus(reservation.id, 'APPROVED'),
              backgroundColor: AppColors.primaryDark,
              borderRadius: 8,
              child: const Text(
                "수락하기",
                style: TextStyle(color: AppColors.textLight),
              ),
            )),
          ],
        );
      case 'APPROVED':
        return Row(
          children: [
            Expanded(
                child: RectangularElevatedButton(
              onPressed: submitReservationStatus(reservation.id, 'STORING'),
              backgroundColor: AppColors.primaryDark,
              borderRadius: 8,
              child: const Text(
                "보관 시작",
                style: TextStyle(color: AppColors.textLight),
              ),
            )),
          ],
        );
      case 'STORING':
        return Row(
          children: [
            Expanded(
                child: RectangularElevatedButton(
              onPressed: submitReservationStatus(reservation.id, 'COMPLETE'),
              backgroundColor: AppColors.backgroundLightRed,
              borderRadius: 8,
              child: const Text(
                "보관 종료",
                style: TextStyle(color: AppColors.textRed),
              ),
            )),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 로딩 중일 때
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text(
          '예약 상세',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                Text(
                  reservation.memberNickname ?? "사용자",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      overflow: TextOverflow.ellipsis),
                ),
                const Text(
                  ' 님의 예약',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Text(
                  "현재 상태 ",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  width: 4,
                ),
                StatusText(reservation.status),
                const SizedBox(
                  width: 4,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 짐 정보
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: MediaQuery.of(context).size.width * 0.3),
              decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0.5, 1.5),
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 0.05,
                        spreadRadius: 0.5),
                  ]),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.luggage, color: AppColors.primaryDark),
                            Text(' 소형',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Spacer(),
                        Text(smallCount.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.luggage, color: AppColors.primaryDark),
                            Text(' 중형',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Spacer(),
                        Text(mediumCount.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.luggage, color: AppColors.primaryDark),
                            Text(' 대형',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Spacer(),
                        Text(largeCount.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 짐 사진 섹션
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: const Text(
                  '짐 사진',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                )),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Row(
                // TODO image 반복문으로 순회 -> 2개 이상이면 슬라이딩하도록
                children: [
                  SizedBox(
                    width: 300,
                    height: 200, // 이미지 슬라이더의 높이
                    child: dummyImages.length == 1
                        ? Center(
                            // 사진이 1개인 경우
                            child: Image.network(
                              dummyImages[0],
                              fit: BoxFit.cover,
                            ),
                          )
                            : SizedBox(
                              // 사진이 2개 이상인 경우
                              child: PageView.builder(
                                                        controller: PageController(viewportFraction: dummyImages.length == 2 ? 0.8 : 1.0),
                                                        itemCount: dummyImages.length,
                                                        itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Image.network(
                                  // imageUrls[index],
                                  dummyImages[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                                                        },
                                                      ),
                            ),
                  ),

                  /*

                  Expanded(
                    child: NetworkImageRect(
                      url: 'https://via.placeholder.com/150',
                      width: 125,
                      height: 125,
                      borderRadius: 8,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NetworkImageRect(
                      url: 'https://via.placeholder.com/150',
                      width: 125,
                      height: 125,
                      borderRadius: 8,
                    ),
                  ),
                   */
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 부적절한 보관물 확인
            const InformationStatement(
                content: "부적합한 보관물이 있는지 확인해주세요.", size: 14),

            const SizedBox(height: 16),
            const Divider(
              thickness: 0.15,
            ),
            // 결제 정보
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '결제 예상금액',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        reservation.paymentAmount.toString(),
                        /* TODO 가격 */
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        '짐',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        '포인트',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const InformationStatement(
              content: "금액은 실 보관 시 달라질 수 있어요",
              size: 12,
            ),
            const SizedBox(
              height: 8,
            ),

            // 버튼, 상태마다 다르게
            buildBottomButton(reservation.status),
          ],
        ),
      ),

      bottomNavigationBar: null, // TODO
    );
  }
}

class InformationStatement extends StatelessWidget {
  final String content;
  final double? size;

  const InformationStatement({super.key, required this.content, this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: AppColors.textDark,
          size: size,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          content,
          style: TextStyle(color: AppColors.textDark, fontSize: size),
        ),
      ],
    );
  }
}
