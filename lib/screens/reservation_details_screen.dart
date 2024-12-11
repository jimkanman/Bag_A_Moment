import 'dart:io';

import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/models/storage_model.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/widgets/network_image_rect.dart';
import 'package:bag_a_moment/widgets/rectangular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../services/api_service.dart';
import '../widgets/Jimkanman_bottom_navigation_bar.dart';
import '../widgets/dialog.dart';

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
  int smallCount = 0;
  int mediumCount = 0;
  int largeCount = 0;
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
    await processLuggageAsync();
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
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('예약 상태가 변경되었습니다.'),
            content: Text('예약 상태가 $status로 변경되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReservationDetailsScreen(reservation: reservation),
        ),
      );
    };
  }

  Widget StatusWidget(String status) {
    var color;
    var text;
    switch (status.toUpperCase()) {
      case 'PENDING':
        text = '대기 중';
        color = Colors.black;
      case 'REJECTED':
        text = '거절';
        color = AppColors.statusRed;
      case 'APPROVED':
        text = '수락';
        color = AppColors.primaryDark;
      case 'STORING':
        text = '보관 중';
        color = AppColors.statusblue;
      case 'COMPLETE':
        text = '수령 완료';
        color = AppColors.statusgrey;
      default:
        return const Text('');
    }
    return Container(
      width: 80,
      height: 24,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: color),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 0.14,
          ),
        ),
      ),
    );
  }

  Widget buildBottomButton(String status) {
    print("버튼 생성: $status");
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Row(
          children: [
            Expanded(
                child: RectangularElevatedButton(
                  onPressed: submitReservationStatus(
                      reservation.id, 'REJECTED'),
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
                  onPressed: submitReservationStatus(
                      reservation.id, 'APPROVED'),
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                _CheckAndStoreScreen(reservation: reservation,)));
                  },
                  backgroundColor: AppColors.primaryDark,
                  borderRadius: 8,
                  child: const Text(
                    "예약인원이 도착했어요",
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
                  onPressed: submitReservationStatus(
                      reservation.id, 'COMPLETE'),
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
      resizeToAvoidBottomInset: true,
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
                StatusWidget(reservation.status),
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
                  horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.3),
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
                        controller: PageController(
                            viewportFraction:
                            dummyImages.length == 2 ? 0.8 : 1.0),
                        itemCount: reservation.luggage.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Image.network(
                              reservation.luggage[index].imagePath??
                                  AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
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
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              spreadRadius: 0.5,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.only(
          top: 16,
          left: 12,
          right: 12,
          bottom: 8,
        ),
        child: reservation.status.toUpperCase() == 'COMPLETE' ||
            reservation.status.toUpperCase() == 'REJECTED'
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '만료되거나 거절된 주문입니다.',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '결제 예상금액',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        reservation.paymentAmount.toString(),
                        /* TODO 가격 */
                        style: const TextStyle(
                          fontSize: 40,
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
                            fontSize: 24,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        '포인트',
                        style: TextStyle(
                            fontSize: 24,
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

class _CheckAndStoreScreen extends StatefulWidget {
  final StorageReservation reservation;
  const _CheckAndStoreScreen({
    Key? key,
    required this.reservation,
  }) : super(key: key);
  @override
  State<_CheckAndStoreScreen> createState() => _CheckAndStoreScreenState();
}

class _CheckAndStoreScreenState extends State<_CheckAndStoreScreen> {
  late StorageReservation reservation;
  late ApiService _apiService;
  int smallCount = 0;
  int mediumCount = 0;
  int largeCount = 0;
  late final int smallPricePerHour;
  late final int mediumPricePerHour;
  late final int largePricePerHour;
  late final int userId;
  late final String? jwt;
  bool isLoading = true;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    initialize();
    reservation=widget.reservation;
  }
  Future<void> processLuggageAsync() async {
    await Future.forEach(reservation.luggage, (element) async {
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
  Future<void> getPricePerHour() async {
    final storageid=reservation.storageId;
    print(storageid);
    final StorageModel storageModel=await _apiService.get("storages/$storageid", fromJson: (item) => StorageModel.fromJson(item));
    smallPricePerHour=storageModel.backpackPricePerHour;
    mediumPricePerHour=storageModel.carrierPricePerHour;
    largePricePerHour=storageModel.miscellaneousItemPricePerHour;
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
    await processLuggageAsync();
    await getPricePerHour();
    print("Reservation: ${reservation.id}");
    setState(() {
      isLoading = false; // 데이터 로드 완료
    });
  }
  Future<void> _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('짐 확인 및 보관'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Color(0xFFF7F7F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 20,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '보관 시간',
                                      style: TextStyle(
                                        color: Color(0xFF2CB598),
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0.05,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '은',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0.05,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' 아래',
                                      style: TextStyle(
                                        color: Color(0xFF2CB598),
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0.05,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '와 같아요',
                                      style: TextStyle(
                                        color: Color(0xFF131413),
                                        fontSize: 20,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w600,
                                        height: 0.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Color(0xFFCEF6EC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                            DateFormat("MM/dd HH:mm").format(DateTime.parse(reservation.startDateTime)),
                          style: TextStyle(
                            color: Color(0xFF2CB598),
                            fontSize: 13,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.65,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Text(
                                '~',
                                style: TextStyle(
                                  color: Color(0xE5C8F4E9),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Color(0xFFCEF6EC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                            DateFormat("MM/dd HH:mm").format(DateTime.parse(reservation.endDateTime)),
                              style: TextStyle(
                                color: Color(0xFF2CB598),
                                fontSize: 13,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '마지막으로',
                                    style: TextStyle(
                                      color: Color(0xFF101010),
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 짐을 확인',
                                    style: TextStyle(
                                      color: Color(0xFF2CB598),
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '해주세요  ',
                                    style: TextStyle(
                                      color: Color(0xFF060606),
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildJimCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              spreadRadius: 0.5,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.only(
          top: 16,
          left: 12,
          right: 12,
          bottom: 8,
        ),
        child: reservation.status.toUpperCase() == 'COMPLETE' ||
            reservation.status.toUpperCase() == 'REJECTED'
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.3),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '만료되거나 거절된 주문입니다.',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.3),
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
                        Spacer(),
                        Text(smallPricePerHour.toString(),
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
                        Spacer(),
                        Text(mediumPricePerHour.toString(),
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
                        Spacer(),
                        Text(largePricePerHour.toString(),style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '결제 예상금액',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        reservation.paymentAmount.toString(),
                        /* TODO 가격 지금 짐 추가된거 반영할 것 */
                        style: const TextStyle(
                          fontSize: 40,
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
                            fontSize: 24,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        '포인트',
                        style: TextStyle(
                            fontSize: 24,
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
            Row(
              children: [
                Expanded(
                    child: RectangularElevatedButton(
                      onPressed: submitReservationStatus(
                          reservation.id, 'REJECTED'),
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
                      onPressed:(){
                        submitReservationStatus(reservation.id, 'STORING');
                      },
                      backgroundColor: AppColors.primaryDark,
                      borderRadius: 8,
                      child: const Text(
                        "보관하기",
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  submitReservationStatus(int reservation_id, String status) {
    return () async {
      try{
        await _apiService.patch(
          'reservations/$reservation_id/status?status=$status',
          fromJson: (json) => json,
        );
        showDialog(
          context: context,
          builder: (context){
            return CustomDialogUI(padding: EdgeInsets.symmetric(horizontal: 12),onPressed: (){},text: "완료",); // 위젯으로 만들어놓은 UI가져오기
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReservationDetailsScreen(reservation: reservation),
          ),
        );
        print('Reservation status updated to $status');
      }catch(e){
        //alert 띄우기
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류'),
              content: Text(
                '예상치 못한 오류가 발생했습니다.',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    };
  }


  Widget buildJimCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child:
      Column(
        children: reservation.luggage.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8), // 각 카드 사이의 간격
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.luggage, color: AppColors.primaryDark),
                    SizedBox(width: 12),
                    Text(
                      item.type == 'BAG'
                          ? '소형 짐'
                          : item.type == 'LUGGAGE'
                          ? '중형 짐'
                          : '대형 짐',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      item.imagePath ?? AppConstants.DEFAULT_PREVIEW_IMAGE_PATH),
                                  fit: BoxFit.fill,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black.withOpacity(
                                        0.30000001192092896),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: Size(100, 50),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 2,
                        backgroundColor: AppColors.primaryVeryLight,
                        side: const BorderSide(
                          color: AppColors.primaryDark,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _pickImage,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Icon(Icons.camera_alt_outlined,
                                color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '사진 첨부하기',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w800,
                              height: 0.17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(), // List를 반환
      ),
    );
  }
}
