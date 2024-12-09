import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/widgets/rectangular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';


class ReservationCard extends StatelessWidget {
  final List<Luggage> luggage;
  final String previewImagePath;
  final String storageName;
  final String pickupTime;
  final Color buttonBackgroundColor;
  final Text buttonText;
  final Color backgroundColor;
  final VoidCallback? onButtonPressed;

  const ReservationCard({
    super.key,
    List<Luggage>? luggage,
    String? previewImagePath,
    String? storageName,
    String? pickupTime,
    Color? buttonBackgroundColor,
    Text? buttonText,
    Color? backgroundColor,
    this.onButtonPressed
  }): luggage = luggage ?? const [],
  previewImagePath = previewImagePath ?? AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
  storageName = storageName ?? "보관소 이름",
  buttonBackgroundColor = buttonBackgroundColor ?? AppColors.primaryDark,
  buttonText = buttonText ?? const Text("연장 요청", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
  pickupTime = pickupTime ?? "00:00",
  backgroundColor = backgroundColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      height: 136,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // 그림자 색상 (투명도 적용 가능)
            spreadRadius: 1, // 그림자가 퍼지는 정도
            blurRadius: 2, // 그림자의 흐림 정도
            offset: Offset(0, 0), // 그림자의 x, y축 위치 (오프셋)
          ),
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 짐 관련 정보
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 24.0, color: AppColors.textDark),
                const SizedBox(width: 4.0),
                Text(
                  '${luggage.length}개',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16.0),

            // 가운데 이미지 + 보관소 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    previewImagePath,
                    width: 96.0,
                    height: 52.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text("수령 장소", style: TextStyle(fontSize: 8, color: AppColors.textGray),),
                const SizedBox(height: 8.0),
                Text(
                  storageName,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16,),

            // 오른쪽 텍스트 및 버튼 (픽업 예정 시간 / 연장 요청 등)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.backgroundGray,
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '픽업 시간  $pickupTime',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4,),
                      SizedBox(
                        height: 28,
                        width: double.infinity,
                        child: RectangularElevatedButton(
                          borderRadius: 4,
                          onPressed: onButtonPressed,
                          backgroundColor: buttonBackgroundColor,
                          child: buttonText
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

