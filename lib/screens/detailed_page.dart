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
      appBar: AppBar(title: Text(markerInfo['name'] ?? 'Detail'),
      backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
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
              if (markerInfo['tags'] != null)
                Text(
                  '태그:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              Wrap(
                spacing: 10,
                children: markerInfo['tags']
                    .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.green.shade100,
                  )
                ).toList(),
              ),
              // 추가 정보 필요 시 여기에 추가
            ],
          ),
        ),
      );
  }
}



