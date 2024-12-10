import 'dart:convert';

import 'package:bag_a_moment/screens/reservation/reservationRequestScreen.dart';
import 'package:bag_a_moment/screens/reservation/reservationSuccess.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'deliveryRequestScreen.dart';




class ReservationScreen extends StatefulWidget {
  //final int storageId;
  final Map<String, dynamic> info;
  ReservationScreen({required this.info});



  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  final TextEditingController smallBagController = TextEditingController();
  final TextEditingController largeBagController = TextEditingController();
  final TextEditingController specialBagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    smallBagController.text = '0';
    largeBagController.text = '0';
    specialBagController.text = '0';
    print('Received info: ${widget.info}');
  }

  // 가방 개수 초기화
  int smallBagCount = 0;
  int largeBagCount = 0;
  int specialBagCount = 0;


  // 이용 시간 상태 관리
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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
      //endTime: TimeOfDay.now(),
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


  void _submitData() async{
    if (selectedStartDate == null || selectedEndDate == null || startTime == null || endTime == null) {
      print('날짜 & 시간 입력하시오');
      _showErrorDialog('날짜와 시간을 모두 입력하세요.');
      //TODO: 시간 입력하라고 경고 띄우기
      return;
    }


    final startDateTime = formatDateTime(selectedStartDate!, startTime!);
    final endDateTime = formatDateTime(selectedEndDate!, endTime!);


    // 사용자가 텍스트 필드에 입력한 값을 가져옴
    final smallBagCount = int.tryParse(smallBagController.text) ?? 0;
    final largeBagCount = int.tryParse(largeBagController.text) ?? 0;
    final specialBagCount = int.tryParse(specialBagController.text) ?? 0;

    // 디버깅: 텍스트 필드 값 확인
    print('텍스트 필드에 입력된 가방 정보');
    print('Small Bag Count: $smallBagCount');
    print('Large Bag Count: $largeBagCount');
    print('Special Bag Count: $specialBagCount');

    // 서버로 데이터를 전송할 body??
    //TODO:  가방 크기 일단 랜덤값 넣음!!! AR 카메라에서 가져온 크기로 수정할 것채
    final reservationData = {
      'luggage': [
        for (int i = 0; i < smallBagCount; i++) {'type': 'BAG', 'width': 20, 'depth': 15, 'height': 10},
        for (int i = 0; i < largeBagCount; i++) {'type': 'CARRIER', 'width': 40, 'depth': 25, 'height': 20},
        for (int i = 0; i < specialBagCount; i++) {'type': 'MISCELLANEOUS_ITEM', 'width': 50, 'depth': 30, 'height': 25},
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
        Uri.parse('http://3.35.175.114:8080/storages/${widget.info['storageId']}/reservations'),
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
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)); // JSON 디코딩
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





  Widget _buildDatePickerButton(String label, DateTime? date, bool isStartDate) {
    return TextButton(
      onPressed: () => _pickDate(context, isStartDate),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFAF6), // 연한 초록색 배경
        foregroundColor: Colors.teal, // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 라운드 테두리
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 내부 여백
      ),
      child: Text(
        date == null ? label : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        style: TextStyle(color: Color(0xFF1CAF9C),),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.info['name'] ?? '세부 정보',
          style: TextStyle(
            color: Colors.black, // 글씨 색상을 흰색으로 설정
            fontWeight: FontWeight.bold, // 글씨를 볼드체로 설정
            fontSize: 15, // 글씨 크기를 적절히 설정 (옵션)
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 AR 측정 버튼
            Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // 카드 배경 흰색
              borderRadius: BorderRadius.circular(12), // 모서리 둥글게
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // 그림자
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5), // 그림자 위치
                ),
              ],
            ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '보관할 짐을 선택해주세요.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis, // 넘칠 경우 "..."으로 표시
                      maxLines: 1, // 한 줄로 제한
                    ),
                    Align(
                      alignment: Alignment.centerRight, // 버튼을 오른쪽으로 정렬
                      child: TextButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
                        label: const Text(
                          'AR 측정',
                          style: TextStyle(color: Colors.teal, fontSize: 10,),
                        ),
                        onPressed: () {
                          // AR 측정 기능 구현 예정
                        },
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 16),

              // 가방 리스트
                  //TODO: 가방 개수를 AR 카메라에서 받아와야함
                  Container(
                    margin: const EdgeInsets.all(8.0), // 카드와 화면 가장자리 간격
                    padding: const EdgeInsets.all(8.0), // 내부 여백
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFAF6), // 연한 민트색 배경
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // 그림자 색상
                          blurRadius: 5, // 그림자 흐림 정도
                          spreadRadius: 2, // 그림자 퍼짐 정도
                          offset: const Offset(0, 2), // 그림자 위치
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildBagRow('소형', smallBagController, widget.info['backpackPrice']),
                        _buildBagRow('중형', largeBagController, widget.info['suitcasePrice']),
                        _buildBagRow('대형', specialBagController, widget.info['specialPrice']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('가방 크기 기준'),
                              content: const Text('배낭: 40x50x50 이하 \n 캐리어: 80x70x60 이하 \n 특수크기: 그외 '
                                  ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('닫기'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, color: Colors.teal, size: 18),
                        label: const Text(
                          '가방크기 기준 알아보기',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                ]
            ),

          ),




              SizedBox(height: 10),

              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // 카드 배경 흰색
                  borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // 그림자
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5), // 그림자 위치
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [Text('이용시간을 선택해주세요.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Paperlogy',
                        ),
                      ),
                ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDatePickerButton('시작 날짜', selectedStartDate, true),
                        const SizedBox(width: 8), // 버튼 간의 간격을 좁게 설정
                        _buildTimePickerButton('시작 시간', startTime, true),
                        const SizedBox(width: 8), // 버튼 간의 간격을 좁게 설정
                        Text('부터'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDatePickerButton('종료 날짜', selectedEndDate, false),
                        const SizedBox(width: 8),
                        _buildTimePickerButton('종료 시간', endTime, false),
                        const SizedBox(width: 8),
                    Text('까지'),
                      ],
                    ),
                  ]
                ),
              )
              // 이용 시간 선택 섹션
            ],
          ),
        ),
      ),

      //결제 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 버튼과 화면 가장자리 간격
        child: ElevatedButton(
          onPressed: () {
            print('결제 버튼 눌림.\n전달받은 데이터: $widget.info');
            _submitData();
          },

            style: ElevatedButton.styleFrom(
            backgroundColor:
           Color(0xFF4DD9C6),
            minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기 (너비, 높이)
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 둥근 모서리 설정 (12px)
            ),
          ),
          child: Text(
            '결제하기',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
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
  Widget _buildBagRow(String label, TextEditingController controller, int? price) {
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
                  keyboardType: TextInputType.number, // 숫자 키보드
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true, // 텍스트 필드 높이를 줄임
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // 여백 조정
                  ),
                  style: const TextStyle(
                    fontSize: 14, // 글씨 크기를 줄임
                  ),

                  onChanged: (value) {
                    // 입력 값 변경 처리
                    String sanitizedValue = value.replaceAll(RegExp(r'^0+'), ''); // 앞에 있는 0 제거
                    int? newValue = int.tryParse(sanitizedValue) ?? 0;
                    if (newValue == null || newValue < 0) {
                      controller.text = '0'; // 음수나 잘못된 입력은 0으로 설정
                    }
                    controller.value = TextEditingValue(
                      text: newValue.toString(),
                      selection: TextSelection.collapsed(offset: newValue.toString().length), // 커서를 끝으로 이동

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
  Widget _buildTimePickerButton(String label, TimeOfDay? time, bool isStartTime) {
    return TextButton(
      onPressed: () => _pickTime(context, isStartTime),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFFAF6), // 연한 초록색 배경
        foregroundColor: Colors.teal, // 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 라운드 테두리
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 내부 여백
      ),
      child: Text(
        time == null ? label : time.format(context),
        style: TextStyle(color: Color(0xFF1CAF9C)),
      ),
    );
  }
}


//예약 완료 화면
//TODO: 다른 파일로 분리할 것
