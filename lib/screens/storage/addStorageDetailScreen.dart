import 'dart:convert';
import 'dart:io';
import 'package:bag_a_moment/screens/storage/storageManage.dart';
import 'package:bag_a_moment/services/api_service.dart';
import 'package:bag_a_moment/widgets/primarybtn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../widgets/textfield.dart';
import '../core/app_colors.dart';
import '../home/homeScreen.dart';
import '../widgets/textfield.dart';


class StorageDetailScreen extends StatefulWidget {
  // 상위에서 전달받는 값들
  final String name;
  final String phone;
  final String address;
  final String postalCode;
  final String? openTime;
  final String? closeTime;
  final File? image;
  final bool deliveryService;

  const StorageDetailScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    required this.postalCode,
    required this.deliveryService,
    this.openTime,
    this.closeTime,
    this.image,
  }) : super(key: key);

  @override
  _StorageDetailScreenState createState() => _StorageDetailScreenState();
}

class _StorageDetailScreenState extends State<StorageDetailScreen> {
  late ApiService apiService;
  late int userId;
  final FlutterSecureStorage _storage=FlutterSecureStorage();
  final List<String> _availableOptions = [
    "PARKING",
    "CART",
    "BOX",
    "CCTV",
    "INSURANCE",
    "REFRIGERATION",
    "VALUABLES",
    "OTHER"
  ];
  final Map<String, String> optionTranslations = {
    'PARKING': '주차 가능',
    'CART': '카트 사용',
    'BOX': '박스 제공',
    'TWENTY_FOUR_HOURS': '24시간',
    'CCTV': 'CCTV 설치',
    'INSURANCE': '보험 제공',
    'REFRIGERATION': '냉장 보관',
    'VALUABLES': '귀중품 보관',
    'OTHER': '기타',
  };
  // 이 화면에서 관리할 추가 상태들
  final _formKey = GlobalKey<FormState>();
  String description = '';
  List<Map<String, String>> items = [
    {'label': '소형', 'price': '0','data':'backpackPrice'}, // backpackPrice
    {'label': '중형', 'price': '0','data':'carrierPrice'},      // carrierPrice
    {'label': '대형', 'price': '0','data':'miscellaneousPrice'},   // miscellaneousPrice
  ];
  String refundPolicy = '';
  File? _selectedFile;
  List<String> _storageOptions = [];

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _refundPolicyController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> initialize() async{
    final token=await _storage.read(key: 'auth_token');
    if(token==null){
      print("[INFO] 로그인 토큰 없음");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    String? savedUserId=await _storage.read(key: 'user_id');
    String? jwt=await _storage.read(key: 'auth_token');
    userId=int.parse(savedUserId!);

    apiService=ApiService(defaultHeader: {
      'Authorization': jwt ?? '',
    });
  }
  String _timeOfDayToString(String? time) {
    if (time == null) return "00:00"; // 기본값 설정
    try {
      if (time.contains("AM") || time.contains("PM")) {
        // 12시간 형식
        final DateFormat inputFormat = DateFormat("h:mm a");
        final DateFormat outputFormat = DateFormat("HH:mm");
        final DateTime parsedTime = inputFormat.parse(time);
        return outputFormat.format(parsedTime);
      } else {
        // 24시간 형식
        final parts = time.split(":");
        if (parts.length != 2) return "00:00";

        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return "00:00";

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print("Time parsing error: $e");
      return "00:00";
    }
  }
  // Row 생성 로직을 추출한 함수
  List<Widget> _buildRows(List<Map<String, String>> items) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 라벨
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF2CB598)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.shopping_bag,color:AppColors.primaryDark,size: 20),
                  const SizedBox(width: 4),
                  Text(
                    item['label']!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // 고정 텍스트
            const Text(
              '개당',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            // 가격 입력 TextField
            Container(
              width: 80, // TextField의 고정 너비
              child:
              TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: TextEditingController(text: item['price'])..selection = TextSelection.collapsed(offset: item['price']!.length),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: AppColors.primaryDark,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true, // 간격 축소
                  contentPadding: EdgeInsets.all(8), // 내부 여백 조정
                  focusedBorder:
                  OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryDark),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    items[index]['price'] = value; // 값 업데이트
                  });

                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  Future<void> _submitApiData(BuildContext context) async {
    await initialize();

    print("이름: ${widget.name}");
    print("전화번호: ${widget.phone}");
    print("주소: ${widget.address}");
    print("우편번호: ${widget.postalCode}");
    print("설명: ${_descriptionController.text}");
    print("가방 요금: ${items[0]['price']}");
    print("캐리어 요금: ${items[1]['price']}");
    print("기타 물품 요금: ${items[2]['price']}");
    print("영업 시작 시간: ${widget.openTime}");
    print("영업 종료 시간: ${widget.closeTime}");
    print("선택된 이미지 경로: ${widget.image?.path}");
    print("선택된 파일 경로: ${_selectedFile?.path}");
    print("환불 정책: ${_refundPolicyController.text}");
    print("보관 옵션: $_storageOptions");
    print("배송 옵션: ${widget.deliveryService}");
    print("=================================");
    try {
      // MultipartFile 생성
      final List<http.MultipartFile> files = [];

      if (widget.image != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'storageImages',
          widget.image!.path,
          contentType: MediaType('image', 'jpeg'), // MIME 타입 지정
        );
        files.add(imageFile);
      }

      if (_selectedFile != null) {
        final otherFile = await http.MultipartFile.fromPath(
          'termsAndConditions',
          _selectedFile!.path,
        );
        files.add(otherFile);
      }

      final multipartFields = {
        'registerName': widget.name,
        'phoneNumber': widget.phone,
        'detailedAddress': widget.address,
        'postalCode': widget.postalCode,
        'description': _descriptionController.text,
        'backpackPricePerHour': items[0]['price'].toString(),
        'carrierPricePerHour': items[1]['price'].toString(),
        'miscellaneousItemPricePerHour': items[2]['price'].toString(),
        "openingTime": widget.openTime ?? "09:00",
        "closingTime": widget.closeTime ?? "21:00",
        'refundPolicy': _refundPolicyController.text,
        'storageOptions': jsonEncode(_storageOptions),
        'hasDeliveryService': widget.deliveryService.toString(),
      };

      // Form 데이터 전송
      final result = await apiService.postMultipart(
        'storages', // 엔드포인트
        fields: multipartFields,
        files: files,
        fromJson: (data) => data, // 응답 처리 (필요시 매핑 함수 작성)
      );
      print("요청 성공: $result");
    } catch (e) {
      print("요청 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요청 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundMypage,
        appBar: AppBar(
          title: const Text(
            '보관소 등록',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // 서버로 데이터 전송
              _submitApiData(context);
              print("성공");
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => addStorageSuccessScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF31BEB0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              '입력한 정보로 내 보관소 등록하기',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(12.0),
            child: Container(
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 20),
                            child: const Text(
                              '추가 정보를 입력해주세요',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  fontFamily: 'Pretendard'),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            decoration: ShapeDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '가격 설정',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 0.10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFEBFFFA),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 1, color: Color(0xFF2CB598)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 반복적으로 Row를 생성하는 구조
                                      ..._buildRows(items),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '환불 정책',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 0.10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  controller: _refundPolicyController,
                                  hintText: '10분이상 미도착시 환불 불가',
                                  validator: (value) =>
                                  value!.isEmpty ? '보관소 이름을 입력해주세요' : null,
                                ),
                                const SizedBox(height: 24),
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '이용 약관',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 0.10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      _selectedFile == null
                                          ? const Text(
                                        '이용약관.pdf',
                                        style: TextStyle(
                                          color: Color(0xFFC4C3C3),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0.14,
                                        ),
                                      )
                                          : Text(
                                        _selectedFile!.path
                                            .split('/')
                                            .last,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0.14,
                                        ),
                                      ),
                                      Primarybtn(
                                        padding: const EdgeInsets.all(8),
                                        onPressed: _pickFile,
                                        text: '파일 선택',
                                      ),
                                    ]),
                                const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '보관소 설명',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 0.10,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                CustomLargeTextFormField(
                                  controller: _descriptionController,
                                  hintText: '보관소의 상세한 소개를 적어주세요',
                                  validator: (value) =>
                                  value!.isEmpty ? '보관소 소개를 입력해주세요.' : null,
                                  maxlines: 4,
                                ),
                                SizedBox(height: 20),
                                const SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: Text(
                                    '보관소 옵션 선택',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 0.10,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  children: _availableOptions.map((option) {
                                    return ChoiceChip(
                                      label: Text(
                                        optionTranslations[option] ?? option, // 한글 변환, 기본값은 원래 문자열
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _storageOptions.contains(option)
                                              ? Colors.white // 선택된 상태 글자색
                                              : AppColors.primaryDark, // 선택되지 않은 상태 글자색
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                      backgroundColor: Colors.white, // 선택되지 않은 상태의 배경색
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                                        side: BorderSide(
                                          color: AppColors.primaryDark, // 테두리 색상
                                          width: 1, // 테두리 두께
                                        ),
                                      ),
                                      selectedColor: AppColors.primaryDark, // 선택된 상태의 배경색
                                      selected: _storageOptions.contains(option),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _storageOptions.add(option);
                                          } else {
                                            _storageOptions.remove(option);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ]
                    )
                )
            )
        )
    );
  }

}

class addStorageSuccessScreen extends StatelessWidget {
  const addStorageSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEBFFFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'assets/images/check-circle-broken.png', // 이미지를 넣을 경로
                    //이미지가 안나옴
                    height: 150, // 이미지 크기 설정
                    width: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '보관소 등록을 완료했어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2CB598),
                    fontSize: 16,
                    fontFamily: 'Pretandard',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.50,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Color(0xFF2CB598),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Primarybtn(padding: const EdgeInsets.all(0),
                          onPressed: (){
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }, text: "내 보관소로 이동하기")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}