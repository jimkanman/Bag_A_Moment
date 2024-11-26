import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';


// 상세 페이지
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> markerInfo;
  DetailPage({required this.markerInfo});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(markerInfo['name'] ?? 'Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              markerInfo['name'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(markerInfo['address'] ?? ''),
            SizedBox(height: 8),
            Text(markerInfo['description'] ?? ''),
            SizedBox(height: 16),
            if (markerInfo['image'] != null)
              Image.network(
                markerInfo['image']!,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            // 새 페이지로 네비게이션 버튼 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextPage(
                      info: markerInfo,
                    ),
                  ),
                );
              },
              child: Text('Next Page'),
            ),


          ],
        ),
      ),
    );
  }
}


class NextPage extends StatelessWidget {
  final Map<String, dynamic> info;
  NextPage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info['name'] ?? 'Next Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Next Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
