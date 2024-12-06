import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class CustomTextFormField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
      maxLength: 20,
      validator: validator,
    );
  }
}