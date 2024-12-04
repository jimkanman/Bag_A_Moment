import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bag_a_moment/screens/validation.dart';
class StorageRegistraterScreen extends StatefulWidget {
  @override
  _StorageRegisterScreenState createState() => _StorageRegisterScreenState();
}

class _StorageRegisterScreenState extends State<StorageRegistraterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController(); // 추가된 필드
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _backpackPriceController = TextEditingController(); // 추가된 필드
  final TextEditingController _carrierPriceController = TextEditingController(); // 추가된 필드
  final TextEditingController _miscellaneousPriceController = TextEditingController(); // 추가된 필드
  final TextEditingController _refundPolicyController = TextEditingController();
  final List<String> _availableOptions = ["PARKING",
    "CART", "BOX", "CCTV", "INSURANCE", "REFRIGERATION", "VALUABLES", "OTHER"];
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
  // 배송 서비스 여부를 저장하는 boolean 변수
  bool _deliveryService = false;


  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  File? _selectedImage;
  File? _selectedFile;
  List<String> _storageOptions = [];

  Future<void> _pickTime(bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '보관소 등록',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFE8F5F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 버튼 색상
      ),
      body: Container(
        color: Color(0xFFE8F5F3), // 배경 색상
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0), // 스크롤 가능하도록 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본 정보를 입력해주세요.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 보관소 이름
                      Text('보관소 이름'),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: '중앙 보관소'),
                        maxLength: 200,
                        validator: (value) => value!.isEmpty ? '보관소명을 입력해주세요.' : null,
                      ),
                      SizedBox(height: 16),

                      // 연락처
                      Text('연락처'),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        //숫자만 입력 가능
                        keyboardType: TextInputType.phone,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: '예) 010-xxxx-xxxx',
                        ),
                        validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요.' : null,
                      ),
                      SizedBox(height: 16),

                      // 주소
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(
                          labelText: '우편번호',
                          hintText: '우편번호를 검색해주세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: Icon(Icons.search),
                        ),
                        maxLength: 10,
                        validator: (value) => value!.isEmpty ? '우편번호를 입력해주세요.' : null,
                      ),
                      SizedBox(height: 16),

                      // 상세주소
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: '상세주소',
                          hintText: '예) 아파트명, 동 호수',

                        ),
                        maxLength: 30,
                        validator: (value) => value!.isEmpty ? '주소를 입력해주세요.' : null,
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 250,
                        height: 30,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              height: 25,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: FlutterLogo(),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(height: 8),
                          Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF4DD9C6)),
                            SizedBox(width: 8),
                            Text(
                                '자세히 적어주실수록 방문율이 높아져요',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF2CB598),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0.15,
                                ),
                              ),
                            ],
                        ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      //사진 추가
                      Text(
                        '보관소 사진 추가',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 왼쪽: 사진 미리보기
                          _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                              _selectedImage!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                          ),
                          SizedBox(height: 12),
                          // 오른쪽: 사진 첨부 버튼
                          GestureDetector(
                            onTap: _pickImage, // 이미지를 선택하는 함수 호출
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF4DD9C6), width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, color: Color(0xFF4DD9C6), size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    '사진 첨부하기',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4DD9C6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.info, color: Color(0xFF4DD9C6)),
                          SizedBox(width: 8),
                          Text(
                            '최소 1개의 사진을 첨부해주세요',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // 배송 서비스 체크박스
                      Row(
                        children: [
                          Checkbox(
                            value: _deliveryService, // 기본 체크 상태
                            onChanged: (value) {
                              setState(() {
                                _deliveryService = value!;
                              });
                            },
                          ),
                          Text(
                            '배송 서비스를 제공합니다',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // 운영 시간
                      Text(
                        '운영시간',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true, // 스크롤 상충 방지
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 7, // 요일 수
                        itemBuilder: (context, index) {
                          final days = ['월', '화', '수', '목', '금', '토', '일'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    days[index],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text('운영 시간: '),
                                TextButton(
                                  onPressed: () => _pickTime(true),
                                  child: Text(_openTime == null ? '시작 시간 선택' : _openTime!.format(context)),
                                ),
                                SizedBox(width: 16),
                                TextButton(
                                  onPressed: () => _pickTime(false),
                                  child: Text(_closeTime == null ? '종료 시간 선택' : _closeTime!.format(context)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // 등록 버튼
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            print('등록 버튼 클릭됨');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4DD9C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: Text(
                            '등록',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


