import 'package:flutter/material.dart';

const int primaryColor = 0xFF49E0C0;

Map<int, Color> color = {
  50: Color(0xFFE0F7F5),
  100: Color(0xFFB3EDE5),
  200: Color(0xFF80E3D6),
  300: Color(0xFF4DD9C6),
  400: Color(0xFF26D1BA),
  500: Color(primaryColor),  // 기본 색상
  600: Color(0xFF43CBBA),
  700: Color(0xFF3AC4B5),
  800: Color(0xFF31BEB0),
  900: Color(0xFF21B2A6),
};

final MaterialColor customSwatch = MaterialColor(primaryColor, color);

final ThemeData appTheme = ThemeData(
  primarySwatch: customSwatch,
  primaryColor: Color(primaryColor),
  scaffoldBackgroundColor: Colors.white, // 기본 배경색 설정
);