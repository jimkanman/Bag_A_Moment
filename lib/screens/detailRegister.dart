import 'package:bag_a_moment/screens/registerStorage.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'validationRegister.dart';
import 'package:file_picker/file_picker.dart';

class DetailRegisterScreen extends StatefulWidget{
  final String name;
  final String phone;
  final String address;
  final String postalCode;
  final String? openTime;
  final String? closeTime;
  final File? image;
  final bool deliveryService;
  //1차 전송받은 데이터
  const DetailRegisterScreen({
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
  _DetailRegister creatState() => _DetailRegister();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
    //이게 왜필요함?
  }

}


class _DetailRegister extends State<StorageRegistraterScreen> {
  _DetailRegister();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
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
  File? _selectedFile;
  List<String> _storageOptions = [];

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
      appBar: AppBar(title: Text('세부 정보 입력')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: '주소'),
              validator: (value) => value!.isEmpty ? '주소를 입력하세요' : null,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ValidationRegister(
                        name: widget.name,
                        phone: widget.phone,
                        address: widget.address,
                        postalCode: widget.postalCode,
                        deliveryService: widget.deliveryService,


                      ),
                    ),
                  );

                }
              },
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }


}
