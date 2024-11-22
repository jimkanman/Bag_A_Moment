import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';


// 상세 페이지
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> markerInfo;

  const DetailPage({Key? key, required this.markerInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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