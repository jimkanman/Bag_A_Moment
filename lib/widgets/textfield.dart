import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class CustomTextFormField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxlines;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxlines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxlines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 0.14,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

class CustomLargeTextFormField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxlines;

  const CustomLargeTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxlines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxlines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 0.14,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textGray),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}