import 'package:bag_a_moment/screens/detailRegister.dart';
import 'package:bag_a_moment/screens/validationRegister.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bag_a_moment/screens/validation.dart';
class StorageRegistraterScreen extends StatefulWidget {

  final String name;
  final String phone;
  final String address;
  final String postalCode;
  final bool deliveryService;

  const StorageRegistraterScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    required this.postalCode,
    required this.deliveryService,
  }) : super(key: key);
  @override
  _StorageRegisterScreenState createState() => _StorageRegisterScreenState();



}

class _StorageRegisterScreenState extends State<StorageRegistraterScreen> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController(); // 추가된 필드


  // 배송 서비스 여부를 저장하는 boolean 변수
  bool _deliveryService = false;


  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }



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
          child: Form(
          key: _formKey, // FormKey 할당
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본 정보를 입력해주세요.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
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
                      SizedBox(height: 5),
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
                              child: Icon(Icons.info, color: Color(0xFF4DD9C6), size: 20,),
                            ),
                            const SizedBox(width: 6),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                SizedBox(width: 3),
                                Text(
                                  '자세히 적어주실수록 방문율이 높아져요',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF2CB598),
                                    fontSize: 12,
                                    //fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 0.15,
                                  ),
                                ),
                              ],
                            ),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFF4DD9C6), width: 2),
                            ),
                                child: Icon(
                                  Icons.image,
                                  color: Color(0xFF4DD9C6),
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
                      Center(
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF4DD9C6), size: 20,),
                            SizedBox(width: 8),
                            Text(
                              textAlign: TextAlign.center,
                              '최소 1개의 사진을 첨부해주세요',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2CB598),
                                fontWeight: FontWeight.w600,
                                height: 0.15,),
                            ),
                          ],
                        ),
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
                            checkColor: Color(0xFF2CB598),
                            activeColor: Color(0xFFE0F7F5),

                          ),
                          Text(
                            '배송 서비스를 제공합니다',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2CB598),),
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
                        shrinkWrap: true, // 부모 위젯에 따라 크기 조정
                        physics: NeverScrollableScrollPhysics(), // 내부 스크롤 방지
                        itemCount: 7, // 요일 수
                        itemBuilder: (context, index) {
                          final days = ['월', '화', '수', '목', '금', '토', '일'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Row 내부 요소를 중앙 정렬
                              crossAxisAlignment: CrossAxisAlignment.center, // Row의 높이 기준으로 중앙 정렬
                              children: [
                                 Text(
                                      days[index],
                                      textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                      style: TextStyle(fontSize: 16),
                                    ),
                                SizedBox(width: 8),
                                Row(

                                    children: [
                                      SizedBox(width: 3),
                                      TextButton(
                                        onPressed: () => _pickTime(true),
                                        child: Text(
                                          _openTime == null ? '00:00' : _openTime!.format(context),
                                          style: TextStyle(
                                            color: Color(0xFF2CB598),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text('~'),
                                      TextButton(
                                        onPressed: () => _pickTime(false),
                                        child: Text(
                                          _closeTime == null ? '23:59' : _closeTime!.format(context),
                                          style: TextStyle(
                                            color: Color(0xFF2CB598),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
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
                            if (_formKey.currentState!.validate()) {
                              if (_openTime == null || _closeTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('운영 시간을 선택해주세요.')),
                                );
                                return; // 검증 실패 시 실행 중단
                              }
                              print('등록 버튼 클릭됨');
                              print('1111111디버깅디버깅디버깅디버깅디버깅');
                              print('Name: ${_nameController.text}');
                              print('Phone: ${_phoneController.text}');
                              print('Address: ${_addressController.text}');
                              print('Postal Code: ${_postalCodeController.text}');
                              print('Opening Time: ${_openTime?.format(context)}');
                              print('Closing Time: ${_closeTime?.format(context)}');
                              print('Selected Image: ${_selectedImage?.path}');


                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailRegisterScreen(
                                        name: _nameController.text,
                                        phone: _phoneController.text,
                                        address: _addressController.text,
                                        postalCode: _postalCodeController.text,
                                        deliveryService: _deliveryService,



                                      ),
                                ),
                              );
                            };

                          },

                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Color(0xFF4DD9C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          ),
                          child: Text(
                            '다음',
                            style: TextStyle(fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Paperlogy',
                              fontWeight: FontWeight.bold,),
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
      ),
    );
  }
}


