import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class Primarybtn extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;

  const Primarybtn({
    Key? key,
    required this.padding,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColors.primaryDark, // 기본 배경색

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 1, // 그림자
          backgroundColor: backgroundColor, // 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // 둥근 테두리
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white), // 텍스트 스타일
        ),
      ),
    );
  }
}

class PrimaryLightbtn extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;

  const PrimaryLightbtn({
    Key? key,
    required this.padding,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.white, // 기본 배경색
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 1, // 그림자
          backgroundColor: backgroundColor, // 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // 둥근 테두리
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.primaryDark), // 텍스트 스타일
        ),
      ),
    );
  }
}