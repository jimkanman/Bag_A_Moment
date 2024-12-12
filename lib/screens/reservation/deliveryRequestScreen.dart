import 'dart:convert';

import 'package:bag_a_moment/screens/reservation/reservationSuccess.dart';
import 'package:bag_a_moment/screens/reservation/reservation_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kpostal/kpostal.dart';

import '../../core/app_colors.dart';
import '../../models/delivery_reservation.dart';
import '../../models/luggage.dart';
import '../../services/api_service.dart';
import '../../widgets/dialog.dart';
import '../../widgets/primarybtn.dart';
import '../../widgets/rectangular_elevated_button.dart';
import '../../widgets/textfield.dart';



class DeliveryrequestScreen extends StatefulWidget {
  //final int storageId;
  final Map<String, dynamic> info;

  DeliveryrequestScreen({required this.info});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<DeliveryrequestScreen> {
  late ApiService _apiService=ApiService();
  late int? smallPricePerHour = 0;
  late int? mediumPricePerHour = 0;
  late int? largePricePerHour = 0;
  DeliveryReservation reservation = DeliveryReservation(
    luggage: [],
  );


  final TextEditingController _addressController = TextEditingController();
  final TextEditingController receiverZipController = TextEditingController();
  final TextEditingController _detailaddressController =
  TextEditingController();

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
      //부피를 바탕으로 해당 가방 추가
      if(volume<=100) {
        reservation = reservation.copyWith(
          luggage: [
            ...reservation.luggage,
            Luggage(
              type: 'BAG',
              width: _volumeData['width'],
              depth: _volumeData['depth'],
              height: _volumeData['height'],
            ),
          ],
        );
      }
      else if(volume<=200){
        reservation = reservation.copyWith(
          luggage: [
            ...reservation.luggage,
            Luggage(
              type: 'CARRIER',
              width: _volumeData['width'],
              depth: _volumeData['depth'],
              height: _volumeData['height'],
            ),
          ],
        );
      }
      else{
        reservation = reservation.copyWith(
          luggage: [
            ...reservation.luggage,
            Luggage(
              type: 'MISCELLANEOUS_ITEM',
              width: _volumeData['width'],
              depth: _volumeData['depth'],
              height: _volumeData['height'],
            ),
          ],
        );
      }
      _updateBagCounts();
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
    initialize();
    setState(() {
      isloading = false;
    });
  }
  Future<void> initialize() async{
    final token=await secureStorage.read(key: 'auth_token');
    if(token==null){
      print("[INFO] 로그인 토큰 없음");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }
    print("token 값$token");
    String? jwt=await secureStorage.read(key: 'auth_token');

    _apiService=ApiService(defaultHeader: {
      'Authorization': jwt ?? '',
    });
  }
  // 가방 개수 초기화
  int smallBagCount = 0;
  int largeBagCount = 0;
  int mediumBagCount = 0;

  // 이용 시간 상태 관리
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  //이미지 상태관리
  List<File?> _selectedImage = [];

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
  Widget receiverZipTextField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: receiverZipController,
            readOnly: true,
            decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textGray, width: 1),
              ),
              hintText: "우편번호",
              hintStyle: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return KpostalView(
                    callback: (Kpostal result) {
                      receiverZipController.text = result.postCode;
                      _addressController.text = result.address;
                    },
                  );
                },
              ),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: Size(100, 50),
            elevation: 2,
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text("우편 번호 찾기"),
        ),
      ],
    );
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
    _updateBagCounts();
    _calculateTotalPrice();
    _selectedImage.add(null);
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
        case 'CARRIER':
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
                      items: ['BAG', 'CARRIER', 'MISCELLANEOUS_ITEM']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'BAG'
                                ? '소형'
                                : value == 'CARRIER'
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
                                  image: (index < _selectedImage.length && _selectedImage[index] != null)
                                      ? FileImage(_selectedImage[index]!)
                                      : NetworkImage('https://via.placeholder.com/150'),
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
      print('날짜 & 시간 없음');
      showDialog(
          context: context,
          builder: (context){return
            CustomDialogUI(padding: EdgeInsets.zero, onPressed: (){}, content: "날짜와 시간을 입력해주세요", title: "오류");}
      );
      return;
    }
    //reservation model 내용 출력
    print('예약 정보: $reservation');

    final startDateTime = formatDateTime(selectedStartDate!, startTime!);
    final endDateTime = formatDateTime(selectedEndDate!, endTime!);

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
    final reservationData = {
      'luggage': reservation.luggage,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'destinationPostalCode': receiverZipController.text,
      'destinationAddress': "${_addressController.text} ${_detailaddressController.text}",
      'deliveryArrivalDateTime': endDateTime,
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
      final response = await _apiService.post(
        'storages/${widget.info['storageId']}/delivery-reservations',
        requestBody: reservationData,
        fromJson: (data) => data,
      );

      print("selectedimage 길이:${_selectedImage.length}");
      _apiService.postMultipart(
        // reservation id로 요청 보냄
        'reservations/${response['id']}/images',
        fields: {},
        files: _selectedImage
            .where((file) => file != null) // null이 아닌 파일만 처리
            .map((file) => http.MultipartFile(
          'luggageImages',
          file!.readAsBytes().asStream(), // null이 아닌 파일만 들어오므로 non-nullable 처리
          file.lengthSync(),
          filename: file.path.split('/').last,
        )).toList(),
        fromJson: (data) => data,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationsuccessPage(
            info: {
              ...widget.info,
              ...reservationData,
            },
          ),
        ),
      );
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
          decoration: const ShapeDecoration(
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 20),
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
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8, vertical: 20),
                child: Row(
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
                                text: '배송지',
                                style: TextStyle(
                                  color: Color(0xFF2CB598),
                                  fontSize: 20,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  height: 0.05,
                                ),
                              ),
                              TextSpan(
                                text: '를 입력해주세요',
                                style: TextStyle(
                                  color: Colors.black,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '주소',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    receiverZipTextField(),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: _addressController,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: AppColors.textGray, width: 1),
                        ),
                        hintText: "우편번호 찾기를 통해 주소를 검색해주세요.",
                        hintStyle: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        counterText: "",
                      ),
                      maxLength: 50,
                      validator: (value) =>
                      value!.isEmpty ? '우편번호 찾기를 통해 주소를 검색해주세요' : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '상세주소',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          height: 0.10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _detailaddressController,
                      hintText: 'ex) 아파트명, 동, 호수',
                      validator: (value) =>
                      value!.isEmpty ? '상세주소를 입력해주세요' : null,
                    ),
                  ],
                ),
              ),
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
class AddressInputCard extends StatelessWidget {
  final TextEditingController userInputPostalCodeController;
  final TextEditingController userInputAddressController;

  AddressInputCard({
    required this.userInputPostalCodeController,
    required this.userInputAddressController,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주소 입력',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: userInputPostalCodeController,
              decoration: InputDecoration(
                labelText: '우편번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: userInputAddressController,
              decoration: InputDecoration(
                labelText: '주소',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.streetAddress,
            ),
          ],
        ),
      ),
    );
  }
}
