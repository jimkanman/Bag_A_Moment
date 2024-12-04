import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bag_a_moment/screens/validation.dart';
class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
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
        title: Text('보관소 등록하기',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF43CBBA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기본 정보 입력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '보관소명'),
                maxLength: 200,
                validator: (value) => value!.isEmpty ? '보관소명을 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: '전화번호'),
                maxLength: 20,
                validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(labelText: '우편번호'),
                maxLength: 10,
                validator: (value) => value!.isEmpty ? '우편번호를 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: '보관소 주소'),
                maxLength: 30,
                validator: (value) => value!.isEmpty ? '주소를 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('운영 시간: '),
                  TextButton(
                    onPressed: () => _pickTime(true),
                    child: Text(_openTime == null ? '시작 시간 선택' : _openTime!.format(context)),
                  ),
                  Text(' ~ '),
                  TextButton(
                    onPressed: () => _pickTime(false),
                    child: Text(_closeTime == null ? '종료 시간 선택' : _closeTime!.format(context)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: '보관소 소개'),
                maxLength: 300,
                validator: (value) => value!.isEmpty ? '보관소 소개를 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              Text('보관소 이미지 선택'),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100, width: 100)
                  : IconButton(
                    icon: Icon(Icons.add_a_photo),
                onPressed: _pickImage,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _backpackPriceController,
                decoration: InputDecoration(labelText: '가방 한개당 가격 (원)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '가격을 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _carrierPriceController,
                decoration: InputDecoration(labelText: '캐리어 한개당 가격 (원)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '가격을 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _miscellaneousPriceController,
                decoration: InputDecoration(labelText: '기타 물품 가격 (원)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '가격을 입력해주세요.' : null,
              ),
              SizedBox(height: 10),
              Text('환불 정책'),
              TextFormField(
                controller: _refundPolicyController,
                decoration: InputDecoration(labelText: '환불 정책 입력'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Text('약관 파일 업로드'),
              _selectedFile != null
                  ? Text(_selectedFile!.path.split('/').last)
                  : TextButton(
                onPressed: _pickFile,
                    child: Text('파일 선택'),
              ),
              SizedBox(height: 10),

              // 배송 서비스 체크박스
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '배송 서비스 제공 여부',
                    style: TextStyle(fontSize: 16),
                  ),
                  Checkbox(
                    value: _deliveryService,
                    onChanged: (value) {
                      setState(() {
                        _deliveryService = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('보관소 옵션 선택'),
              Wrap(
                spacing: 10,
                children: _availableOptions.map((option) {
                  return ChoiceChip(
                    label: Text(
                      optionTranslations[option] ?? option, // 한글 변환, 기본값은 원래 문자열
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Paperlogy',
                      ),
                    ),
                    backgroundColor: Color(0xFF4DD9C6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      side: BorderSide.none, // 외곽선 제거
                    ),
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

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_openTime == null || _closeTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('운영 시간을 선택해주세요.')),
                      );
                      return; // 검증 실패 시 실행 중단
                    }
                    

                    // Debugging: Print each value to verify input
                    print('디버깅디버깅디버깅디버깅디버깅');
                    print('Name: ${_nameController.text}');
                    print('Phone: ${_phoneController.text}');
                    print('Address: ${_addressController.text}');
                    print('Postal Code: ${_postalCodeController.text}');
                    print('Description: ${_descriptionController.text}');
                    print('Backpack Price: ${_backpackPriceController.text}');
                    print('Carrier Price: ${_carrierPriceController.text}');
                    print('Miscellaneous Price: ${_miscellaneousPriceController.text}');
                    print('Opening Time: ${_openTime?.format(context)}');
                    print('Closing Time: ${_closeTime?.format(context)}');
                    print('Selected Image: ${_selectedImage?.path}');
                    print('Selected File: ${_selectedFile?.path}');
                    print('Refund Policy: ${_refundPolicyController.text}');
                    print('Storage Options: $_storageOptions');

                    
                    
                    // 서버에 전송
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ValidationScreen(
                          name: _nameController.text,
                          phone: _phoneController.text,
                          address: _addressController.text,
                          postalCode: _postalCodeController.text,
                          description: _descriptionController.text,
                          backpackPrice: _backpackPriceController.text,
                          carrierPrice: _carrierPriceController.text,
                          miscellaneousPrice: _miscellaneousPriceController.text,
                          openTime: _openTime?.format(context),
                          closeTime: _closeTime?.format(context),
                          image: _selectedImage,
                          file: _selectedFile,
                          refundPolicy: _refundPolicyController.text,
                          storageOptions: _storageOptions,
                          deliveryService: _deliveryService,
                        ),
                      ),

                  );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4DD9C6),
                  minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기 (너비, 높이)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  '보관소 정보 입력 완료',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Paperlogy',

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
