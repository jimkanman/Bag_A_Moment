import 'dart:convert';

import 'package:bag_a_moment/screens/reservation/reservationRequestScreen.dart';
import 'package:bag_a_moment/screens/reservation/reservationSuccess.dart';
import 'package:bag_a_moment/screens/reservation/reservation_details_screen.dart';
import 'package:bag_a_moment/widgets/primarybtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/luggage.dart';
import '../../models/storage_reservation.dart';
import '../../widgets/rectangular_elevated_button.dart';
import 'deliveryRequestScreen.dart';

class ReservationScreen extends StatefulWidget {
  //final int storageId;
  final Map<String, dynamic> info;

  ReservationScreen({required this.info});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late int? smallPricePerHour = 0;
  late int? mediumPricePerHour = 0;
  late int? largePricePerHour = 0;

  Map<String, int> _volumeData = {};
  static const platform = MethodChannel("com.example.example/message");

  Future<void> _fetchVolumeData() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getVolumeAndroid');
      setState(() {
        _volumeData = {
          'width': result['width'],
          'height': result['height'],
          'depth': result['depth'],
        };
      });
      final volume=_volumeData['width']!+_volumeData['height']!+_volumeData['depth']!;

    } on PlatformException catch (e) {
      print("Failed to get volume: '${e.message}'.");
    }
  }

  bool isloading = true;

  @override
  void initState() {
    super.initState();
    print('Received info: ${widget.info}');
    smallPricePerHour = widget.info['backpackPrice'];
    mediumPricePerHour = widget.info['suitcasePrice'];
    largePricePerHour = widget.info['specialPrice'];
    setState(() {
      isloading = false;
    });
  }

  StorageReservation reservation = const StorageReservation(
    luggage: [],
  );

  // 가방 개수 초기화
  int smallBagCount = 0;
  int largeBagCount = 0;
  int mediumBagCount = 0;

  // 이용 시간 상태 관리
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  //이미지 상태관리
  List<File> _selectedImage = [];

  //이미지 선택
  Future<void> _pickImage(int luggageIndex) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        // luggageIndex 위치에 이미지를 추가
        if (_selectedImage.length > luggageIndex) {
          _selectedImage[luggageIndex] = File(pickedImage.path);
        } else {
          // 빈 공간을 채운 후 이미지 추가
          while (_selectedImage.length <= luggageIndex) {
            _selectedImage.add(File(''));
          }
          _selectedImage[luggageIndex] = File(pickedImage.path);
        }
      });
    }
  }

  void _addJimCard() {
    setState(() {
      reservation = reservation.copyWith(
        luggage: [
          ...reservation.luggage,
          const Luggage(
            type: 'BAG',
            width: 20,
            depth: 15,
            height: 10,
          ),
        ],
      );
    });
  }

  //로그인 토큰, 아이디를 저장
  final secureStorage = FlutterSecureStorage();

  //날짜 시간 저장
  String formatDateTime(DateTime date, TimeOfDay time) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat("yyyy-MM-ddTHH:mm:ss").format(dateTime); // 서버 요구 형식
  }

  // 이용 날짜 상태 관리
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  //날짜 선택
  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
      });
    }
  }

  //시간 선택
  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  void _updateBagCounts() {
    // 각 유형의 카운트를 초기화
    int smallCount = 0;
    int mediumCount = 0;
    int largeCount = 0;

    // 각 짐 유형에 따라 카운트 업데이트
    for (var item in reservation.luggage) {
      switch (item.type) {
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
    }

    // 상태 업데이트
    setState(() {
      smallBagCount = smallCount;
      mediumBagCount = mediumCount;
      largeBagCount = largeCount;
    });
  }

// 최종 가격 계산
  int _calculateTotalPrice() {
    return (smallBagCount * (smallPricePerHour ?? 0)) +
        (mediumBagCount * (mediumPricePerHour ?? 0)) +
        (largeBagCount * (largePricePerHour ?? 0));
  }

  Widget buildJimCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: reservation.luggage.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.luggage, color: AppColors.primaryDark),
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      value: item.type,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            int index = reservation.luggage.indexOf(item);
                            reservation.luggage[index] =
                                item.copyWith(type: newValue);
                            _updateBagCounts();
                          });
                        }
                      },
                      items: ['BAG', 'LUGGAGE', 'MISCELLANEOUS_ITEM']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'BAG'
                                ? '소형'
                                : value == 'LUGGAGE'
                                    ? '중형'
                                    : '대형',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
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
                                  image: _selectedImage.length > index
                                      ? FileImage(_selectedImage[index])
                                      : NetworkImage(
                                          'https://via.placeholder.com/150'),
                                  fit: BoxFit.fill,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                        .withOpacity(0.30000001192092896),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      onPressed: () => _pickImage(index),
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


  //에러 팝업
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _submitData() async {
    if (selectedStartDate == null ||
        selectedEndDate == null ||
        startTime == null ||
        endTime == null) {
      print('날짜 & 시간 입력하시오');
      _showErrorDialog('날짜와 시간을 모두 입력하세요.');
      //TODO: 시간 입력하라고 경고 띄우기
      return;
    }
    //reservation model 내용 출력
    print('예약 정보: $reservation');
    print('시작 날짜: ${reservation.luggage}');
    print('종료 날짜: $selectedEndDate');

    final startDateTime = formatDateTime(selectedStartDate!, startTime!);
    final endDateTime = formatDateTime(selectedEndDate!, endTime!);

    // // 사용자가 텍스트 필드에 입력한 값을 가져옴
    // final smallBagCount = int.tryParse(smallBagController.text) ?? 0;
    // final largeBagCount = int.tryParse(largeBagController.text) ?? 0;
    // final specialBagCount = int.tryParse(specialBagController.text) ?? 0;

    // 디버깅: 텍스트 필드 값 확인
    print('텍스트 필드에 입력된 가방 정보');
    print('Small Bag Count: $smallBagCount');
    print('Large Bag Count: $largeBagCount');
    print('Special Bag Count: $mediumBagCount');

    //AR 카메라에서 받은 w,h,d 값 리스트에 저장
    List<Map<String, dynamic>> luggageData = [];
    Future<void> _addBagData() async {
      try {
        final Map<dynamic, dynamic> result = await platform.invokeMethod('getVolumeAndroid');
        setState(() {
          luggageData.add({
            'type': 'CUSTOM', // 필요한 경우 유형을 지정
            'width': result['width'],
            'height': result['height'],
            'depth': result['depth'],
          });
        });
        print('추가된 데이터: $luggageData');
      } on PlatformException catch (e) {
        print("Failed to get volume: '${e.message}'");
      }
    }



    // 서버로 데이터를 전송할 body??
    //TODO:  가방 크기 일단 랜덤값 넣음!!! AR 카메라에서 가져온 크기로 수정할 것채
    final reservationData = {
      'luggage': [
        for (int i = 0; i < smallBagCount; i++)
          {'type': 'BAG', 'width': 20, 'depth': 15, 'height': 10},
        for (int i = 0; i < largeBagCount; i++)
          {'type': 'CARRIER', 'width': 40, 'depth': 25, 'height': 20},
        for (int i = 0; i < mediumBagCount; i++)
          {
            'type': 'MISCELLANEOUS_ITEM',
            'width': 50,
            'depth': 30,
            'height': 25
          },
      ],
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };

    // 디버깅: 서버에 전송되는 데이터 출력
    print('예약 데이터 (서버 전송): ${jsonEncode(reservationData)}');

    // 여기서 바로 secureStorage에서 토큰을 읽어와 사용
    String? token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      print('토큰이 만료되었습니다. 다시 로그인 해주세요');
      _showErrorDialog('토큰이 만료되었습니다. 다시 로그인 해주세요.');
      return;
    }

    print('예약 정보: ${widget.info}');
    print('가방 정보: $reservationData');

    try {
      final response = await http.post(
        Uri.parse(
            'http://3.35.175.114:8080/storages/${widget.info['storageId']}/reservations'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reservationData),
      );

      //1. 예약 완료 화면으로 이동
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        print('예약 성공! ');
        print('서버 응답: $decodedResponse'); // 서버에서 받은 메시지 확인
        print('서버 응답 상태 코드: ${response.statusCode}');
        print('서버 응답 본문: ${utf8.decode(response.bodyBytes)}');
        // Navigate to PaymentPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationsuccessPage(
              info: {
                ...widget.info,
                ...reservationData,
                'responseMessage': decodedResponse, // 응답 메시지를 전달
              },
            ),
          ),
        );
      } else {
        // 에러 처리
        print('예약 실패 - 상태 코드: ${response.statusCode}');
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)); // JSON 디코딩
        print('디코딩된 응답: $decodedResponse'); // 전체 응답 확인

        //final errorMessage = decodedResponse['message']?.toString() ?? '알 수 없는 오류'; // message 추출

        // message 필드 추출
        String errorMessage = '';
        if (decodedResponse is Map && decodedResponse.containsKey('message')) {
          errorMessage = decodedResponse['message']?.toString() ?? '알 수 없는 오류';
        } else {
          errorMessage = '알 수 없는 오류';
        }
        print('추출된 오류 메시지: $errorMessage'); // 추출된 메시지 확인
        // 팝업에 에러 메시지 표시
        _showErrorDialog('예약 실패: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('예약 실패 ㅠㅠ');
    }
  }

  Widget _buildDatePickerButton(
      String label, DateTime? date, bool isStartDate) {
    return TextButton(
      onPressed: () => _pickDate(context, isStartDate),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFAF6), // 연한 초록색 배경
        foregroundColor: Colors.teal, // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 라운드 테두리
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 내부 여백
      ),
      child: Text(
        date == null
            ? label
            : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: Color(0xFF1CAF9C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          '짐 확인 및 보관',
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
        child: Container(
          width: MediaQuery.of(context).size.width,
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
                      Column(
                        children: [
                          _buildDatePickerButton(
                              '시작 날짜', selectedStartDate, true),
                          _buildTimePickerButton('시작 시간', startTime, true),
                        ],
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
                      Column(
                        children: [
                          _buildDatePickerButton(
                              "종료 날짜", selectedEndDate, false),
                          _buildTimePickerButton('종료 시간', endTime, false),
                        ],
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
                                    text: '보관할',
                                    style: TextStyle(
                                      color: Color(0xFF101010),
                                      fontSize: 20,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 짐을 추가',
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
                    Align(
                      alignment: Alignment.centerRight, // 버튼을 오른쪽으로 정렬
                      child: TextButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.teal),
                        label: const Text(
                          'AR 측정',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 10,
                          ),
                        ),
                        onPressed: () => _fetchVolumeData(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildJimCard(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: PrimaryLightbtn(
                    padding: EdgeInsets.zero,
                    onPressed: _addJimCard,
                    text: "짐 추가하기"),
              )
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                        Text(smallBagCount.toString(),
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
                        Text(mediumBagCount.toString(),
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
                        Text(largeBagCount.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        Spacer(),
                        Text(largePricePerHour.toString(),
                            style: TextStyle(
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
                        _calculateTotalPrice().toString(),
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
                  onPressed: () {}, //TODO
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
                  onPressed: () => _submitData(),
                  backgroundColor: AppColors.primaryDark,
                  borderRadius: 8,
                  child: const Text(
                    "결제하기",
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

  IconData _getIconForLabel(String label) {
    switch (label) {
      case '배낭':
        return Icons.backpack; // 배낭 아이콘
      case '캐리어':
        return Icons.luggage; // 캐리어 아이콘
      case '특수 크기':
        return Icons.add_business; // 특수 크기 아이콘
      default:
        return Icons.help_outline; // 기본 아이콘
    }
  }

  //가방 개수 설정 위젯
  Widget _buildBagRow(
      String label, TextEditingController controller, int? price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForLabel(label), // 아이콘을 label에 따라 결정
                color: Colors.teal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 50, // 숫자 입력 칸의 너비
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  // 숫자 키보드
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true, // 텍스트 필드 높이를 줄임
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0), // 여백 조정
                  ),
                  style: const TextStyle(
                    fontSize: 14, // 글씨 크기를 줄임
                  ),
                  onChanged: (value) {
                    // 입력 값 변경 처리
                    String sanitizedValue =
                        value.replaceAll(RegExp(r'^0+'), ''); // 앞에 있는 0 제거
                    int? newValue = int.tryParse(sanitizedValue) ?? 0;
                    if (newValue == null || newValue < 0) {
                      controller.text = '0'; // 음수나 잘못된 입력은 0으로 설정
                    }
                    controller.value = TextEditingValue(
                      text: newValue.toString(),
                      selection: TextSelection.collapsed(
                          offset: newValue.toString().length), // 커서를 끝으로 이동
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Text(
                price != null ? '$price 원' : '가격 정보 없음',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //시간 설정 위젯
  Widget _buildTimePickerButton(
      String label, TimeOfDay? time, bool isStartTime) {
    return TextButton(
      onPressed: () => _pickTime(context, isStartTime),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFAF6), // 연한 초록색 배경
        foregroundColor: Colors.teal, // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 라운드 테두리
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 내부 여백
      ),
      child: Text(
        time == null ? label : time.format(context),
        style: TextStyle(color: Color(0xFF1CAF9C)),
      ),
    );
  }
}
