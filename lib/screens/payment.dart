import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> info;
  PaymentPage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info['name'] ?? 'Next Page'),
      ),
      body: Center(
        child: Text(
          '예약 결제 화면입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}