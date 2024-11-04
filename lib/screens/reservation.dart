import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("예약 내역"),
      ),
      body: Center(
        child: Text("예약 내역 페이지"),
      ),
    );
  }
}