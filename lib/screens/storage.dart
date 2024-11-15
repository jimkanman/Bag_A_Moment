import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _refundPolicyController = TextEditingController();

  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  File? _selectedImage;
  File? _selectedFile;

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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기본 정보 입력', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '보관소명'),
                maxLength: 200,
                validator: (value) => value!.isEmpty ? '보관소명을 입력해주세요.' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: '전화번호'),
                maxLength: 20,
                validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요.' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: '보관소 주소'),
                maxLength: 30,
                validator: (value) => value!.isEmpty ? '주소를 입력해주세요.' : null,
              ),
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
                controller: _priceController,
                decoration: InputDecoration(labelText: '가방 한개당 가격 (원)'),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 서버에 전송
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('보관소 등록 완료')));
                  }
                },
                child: Text('보관소 정보 입력 완료'),
              ),
            ],
          ),
        ),
      );
  }
}
