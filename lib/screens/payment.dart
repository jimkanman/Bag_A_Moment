import 'package:flutter/material.dart';
import 'dart:io';

class ReservationScreen extends StatefulWidget {
  final Map<String, dynamic> info;
  ReservationScreen({required this.info});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  // 가방 개수 상태 관리
  int smallBagCount = 0;
  int largeBagCount = 0;
  int specialBagCount = 0;

  // 이용 시간 상태 관리
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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

  void _submitData() {
    // 서버로 데이터를 전송할 로직
    final reservationData = {
      'smallBagCount': smallBagCount,
      'largeBagCount': largeBagCount,
      'specialBagCount': specialBagCount,
      'startTime': startTime?.format(context),
      'endTime': endTime?.format(context),
    };

    print('예약 정보: ${widget.info}');
    print('가방 정보: $reservationData');

    // 결제 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          info: {
            ...widget.info,
            ...reservationData,
          },
        ),
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
            color: Colors.white, // 글씨 색상을 흰색으로 설정
            fontWeight: FontWeight.bold, // 글씨를 볼드체로 설정
            fontSize: 20, // 글씨 크기를 적절히 설정 (옵션)
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4DD9C6),
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
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text(
                  widget.info['address'] ?? '주소 정보 없음',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('운영 중 (${widget.info['closingTime'] ?? '미정'} 종료), ${widget.info['distance'] ?? '0m'}'),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 5),
                  Text('${widget.info['rating'] ?? 0}(${widget.info['reviews'] ?? 0}개의 리뷰)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    label: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 5),
                        Text('인증된 사용자',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Paperlogy',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  Chip(
                    label: Row(
                      children: [
                        Icon(Icons.camera, color: Colors.green),
                        SizedBox(width: 10),
                        Text('AR 짐 크기측정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Paperlogy',
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('맡길 짐 수정하기',
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Paperlogy',
              ),
              ),
              Divider(),
              // 가방 개수 선택 섹션
              Column(
                children: [
                  _buildBagRow('작은 가방', smallBagCount, (value) {
                    setState(() {
                      smallBagCount += value;
                    });
                  }),
                  _buildBagRow('큰 여행 가방', largeBagCount, (value) {
                    setState(() {
                      largeBagCount += value;
                    });
                  }),
                  _buildBagRow('특수 크기', specialBagCount, (value) {
                    setState(() {
                      specialBagCount += value;
                    });
                  }),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 5),
                  Text('가방 크기 기준 알아보기'),
                ],
              ),
              Divider(),
              // 이용 시간 선택 섹션
              Text('이용 시간', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimePickerButton('시작 시간', startTime, true),
                  Text('부터'),
                  _buildTimePickerButton('종료 시간', endTime, false),
                  Text('까지'),
                ],
              ),
              SizedBox(height: 20),
        ],
          ),
        ),

        ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 버튼과 화면 가장자리 간격
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4DD9C6),
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

  Widget _buildBagRow(String label, int count, Function(int) onUpdate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: count > 0 ? () => onUpdate(-1) : null,
              ),
              Text(count.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => onUpdate(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(String label, TimeOfDay? time, bool isStartTime) {
    return TextButton(
      onPressed: () => _pickTime(context, isStartTime),
      child: Text(
        time == null ? label : time.format(context),
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> info;
  PaymentPage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info['name'] ?? '결제 페이지'),
      ),
      body: Center(
        child: Text(
          '예약 결제 화면입니다.\n전달받은 데이터: $info',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
