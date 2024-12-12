import 'dart:ui';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';

import '../../widgets/textfield.dart';
import 'package:bag_a_moment/screens/storage/addStorageDetailScreen.dart'
    '';





class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController receiverZipController = TextEditingController();
  final TextEditingController _detailaddressController =
      TextEditingController();
  final days = ["월", "화", "수", "목", "금", "토", "일"];
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

  // 배송 서비스 여부를 저장하는 boolean 변수
  bool _deliveryService = false;
  bool _timeall = true;

  TimeOfDay _openTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = TimeOfDay(hour: 18, minute: 0);
  File? _selectedImage;

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
    print("OPENTIME: $_openTime");
    print("CLOSETIME: $_closeTime");
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }


  String _formatTimeOfDayToHHMM(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
                height: 0.14,
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

  @override
  Widget build(BuildContext context) {
    // final storage = Provider.of<Storage>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundMypage,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '보관소 등록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Debugging: Print each value to verify input
              print('디버깅디버깅디버깅디버깅디버깅');
              print('Name: ${_nameController.text}');
              print('Phone: ${_phoneController.text}');
              print('Address: ${_addressController.text} ${_detailaddressController.text}');
              print('Postal Code: ${receiverZipController.text}');
              print('Opening Time: ${_formatTimeOfDayToHHMM(_openTime)}, $_openTime');
              print('Closing Time: ${_formatTimeOfDayToHHMM(_closeTime)}, $_closeTime');
              print('Selected Image: ${_selectedImage?.path}');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StorageDetailScreen(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    address:
                        "${_addressController.text} ${_detailaddressController.text}",
                    postalCode: receiverZipController.text,
                    openTime: _formatTimeOfDayToHHMM(_openTime),
                    closeTime: _formatTimeOfDayToHHMM(_closeTime),
                    image: _selectedImage,
                    deliveryService: _deliveryService,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            minimumSize: Size(double.infinity, 50),
            // 버튼의 최소 크기 (너비, 높이)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            '다음',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: const Text(
                  '기본 정보를 입력해주세요',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      fontFamily: 'Pretendard'),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        '보관소 이름',
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
                      controller: _nameController,
                      hintText: '중앙보관소',
                      validator: (value) =>
                          value!.isEmpty ? '보관소 이름을 입력해주세요' : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '연락처',
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
                      controller: _phoneController,
                      hintText: 'ex) 010xxxxxxxx',
                      validator: (value) =>
                          value!.isEmpty ? '연락처를 입력해주세요' : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '주소',
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
                          height: 0.14,
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
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.primaryDark,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '자세히 적어주실수록 방문율이 높아져요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2CB598),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0.14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '보관소 사진 등록',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                                        image: _selectedImage != null
                                            ? FileImage(
                                                _selectedImage!) // 수정된 부분
                                            : NetworkImage(
                                                "https://via.placeholder.com/156x148"),
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
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.primaryDark,
                                    size: 28,
                                  ),
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
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: const Icon(
                                Icons.info_outline,
                                color: AppColors.primaryDark,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '되도록 보관소 전체가 보이는 사진을 올려주세요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2CB598),
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 0.14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        '배송 서비스',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          height: 0.10,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _deliveryService,
                          onChanged: (value) {
                            setState(() {
                              _deliveryService = value!;
                            });
                            print("_DELIVERYSERVICE: $_deliveryService");
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          side: BorderSide(
                            color: AppColors.primaryDark,
                            width: 2,
                          ),
                          activeColor: AppColors.primaryDark,
                        ),
                        const Text(
                          '배송 서비스를 제공합니다',
                          style: TextStyle(
                            color: Color(0xFF2CB598),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 0.10,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                '운영시간',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0.10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _timeall,
                                    onChanged: (value) {
                                      setState(() {
                                        _timeall = value!;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    side: BorderSide(
                                      color: AppColors.primaryDark,
                                      width: 2,
                                    ),
                                    activeColor: AppColors.primaryDark,
                                  ),
                                  Text("일괄 적용",
                                      style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                            ...days.map((day) {
                              return DatePickerWidget(
                                date: day,
                                onPickOpenTime: () => _pickTime(true),
                                onPickCloseTime: () => _pickTime(false),
                                opentime: _openTime,
                                closeTime: _closeTime,
                              );
                            }).toList(),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerWidget extends StatelessWidget {
  final String date;
  final VoidCallback onPickOpenTime;
  final VoidCallback onPickCloseTime;
  final TimeOfDay? opentime;
  final TimeOfDay? closeTime;

  const DatePickerWidget({
    super.key,
    required this.date, // 필수 입력값으로 선언
    required this.onPickOpenTime,
    required this.onPickCloseTime,
    required this.opentime,
    required this.closeTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            date,
            style: TextStyle(
              color: Color(0xFF2CB598),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 0.08,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onPickOpenTime,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: AppColors.primaryDark,
                  width: 1,
                ),
              ),
            ),
            child: Text(opentime == null ? "오픈 시간" : opentime!.format(context),
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 0.10,
                )),
          ),
          const SizedBox(width: 8),
          Text("~"),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onPickCloseTime,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: AppColors.primaryDark,
                  width: 1,
                ),
              ),
            ),
            child:
                Text(closeTime == null ? "마감 시각" : closeTime!.format(context),
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0.10,
                    )),
          ),
        ],
      ),
    );
  }
}
