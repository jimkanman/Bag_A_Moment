import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_constants.dart';

class NetworkImageRect extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;
  const NetworkImageRect({
    super.key,
    this.url = AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
    this.width = 75,
    this.height = 75,
    this.borderRadius = 0
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        height: width,
        width: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
