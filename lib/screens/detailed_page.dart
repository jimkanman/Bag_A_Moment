import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';


// 상세 페이지
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> markerInfo;

  const DetailPage({Key? key, required this.markerInfo}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    // storageOptions를 List<String>으로 변환
    final List<String> storageOptions = List<String>.from(markerInfo['storageOptions'] ?? []);


    return Scaffold(
      appBar: AppBar(
        title: Text(markerInfo['name']),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              markerInfo['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Name: ${markerInfo['name']}'),
            Text('Address: ${markerInfo['detailedAddress']}'),
            Text('Postal Code: ${markerInfo['postalCode']}'),
            Text('Storage Options: ${storageOptions.join(', ')}'),
            // 기타 정보 출력
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: (markerInfo['tags'] as List<String>)
                  .map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.green[100],
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}