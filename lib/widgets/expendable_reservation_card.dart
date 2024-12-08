import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/widgets/rectangular_elevated_button.dart';
import 'package:bag_a_moment/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class ExpandableReservationCard extends StatefulWidget {
  final List<Luggage> luggage;
  final String previewImagePath;
  final String storageName;
  final String pickupTime;
  final Color buttonBackgroundColor;
  final Text buttonText;
  final Color backgroundColor;
  final VoidCallback? onButtonPressed;
  final DeliveryReservation? deliveryReservation;
  static final Map<int, GoogleMapController> googleMapControllers = {}; // Controller 저장용 MAP (deliveryId : 컨트롤러)

  // 추가 요소 (터치 시 GoogleMap 렌더링 관련
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  const ExpandableReservationCard({
    super.key,
    List<Luggage>? luggage,
    String? previewImagePath,
    String? storageName,
    String? pickupTime,
    Color? buttonBackgroundColor,
    Text? buttonText,
    Color? backgroundColor,
    this.onButtonPressed,
    this.deliveryReservation,
    this.deliveryLatitude,
    this.deliveryLongitude,
  }):   luggage = luggage ?? const [],
        previewImagePath = previewImagePath ?? AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
        storageName = storageName ?? "보관소 이름",
        buttonBackgroundColor = buttonBackgroundColor ?? AppColors.primaryDark,
        buttonText = buttonText ?? const Text("연장 요청", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        pickupTime = pickupTime ?? "00:00",
        backgroundColor = backgroundColor ?? Colors.white;

  @override
  State<ExpandableReservationCard> createState() => _ExpandableReservationCardState();
}

class _ExpandableReservationCardState extends State<ExpandableReservationCard> {
  bool _isExpanded = false;
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded; // 카드 확장 여부 토글
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
        curve: Curves.easeInOut, // 부드러운 애니메이션 효과
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        height: _isExpanded ? 386 : 136, // 확장 여부에 따라 높이 조절
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // 그림자 색상
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // 기존 카드 내용
            Padding(
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
                        '${widget.luggage.length}개',
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
                          widget.previewImagePath,
                          width: 96.0,
                          height: 52.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        "수령 장소",
                        style: TextStyle(fontSize: 8, color: AppColors.textGray),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.storageName,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // 오른쪽 텍스트 및 버튼 (픽업 예정 시간 / 연장 요청 등)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.backgroundGray,
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '픽업 시간  ${widget.pickupTime}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 28,
                              width: double.infinity,
                              child: RectangularElevatedButton(
                                borderRadius: 4,
                                onPressed: widget.onButtonPressed,
                                backgroundColor: widget.buttonBackgroundColor,
                                child: widget.buttonText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // GoogleMap 컨테이너 (확장 시 표시)
            if (_isExpanded)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Divider(thickness: 0.5, height: 3,),

                     // 배송맨이 이동 중이에요!
                     const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("배송맨", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold ),),
                            Text("이 목적지를 향해 ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
                            Text("이동", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold ),),
                            Text("하고 있어요", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),)
                          ],
                        ),
                      ),

                      // GOOGLE MAP
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            color: Colors.grey[200],
                          ),
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              ExpandableReservationCard.googleMapControllers[widget.deliveryReservation?.deliveryId ?? -1] = controller;
                            },
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(37.5665, 126.9780), // 서울
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('delivery'),
                                position: LatLng(
                                    widget.deliveryLatitude ?? 37.5665,
                                    widget.deliveryLongitude ?? 126.9780),
                                infoWindow: const InfoWindow(title: '배송맨'),
                              ),

                              if(widget.deliveryReservation?.destinationLatitude != null &&
                                  widget.deliveryReservation?.destinationLongitude != null)
                                Marker(
                                  markerId: const MarkerId('delivery'),
                                  position: LatLng(
                                      widget.deliveryReservation!.destinationLatitude ?? 37.5665,
                                      widget.deliveryReservation!.destinationLongitude ?? 126.9780),
                                  infoWindow: const InfoWindow(title: '배송맨'),
                                ),
                            }
                          ),
                        ),
                      ),

                      // 주소 정보
                      const SizedBox(height: 8,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            const Text("도착지", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(widget.deliveryReservation?.destinationAddress ?? "서울특별시 흑석로 84 208관 519호",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end, overflow: TextOverflow.ellipsis,),
                            )
                          ],
                        ),
                      )


                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


    /*  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // 상태를 반전
            });
          },
          child: ReservationCard(
            luggage: widget.luggage,
            previewImagePath: widget.previewImagePath,
            storageName: widget.storageName,
            pickupTime: widget.pickupTime,
            buttonBackgroundColor: widget.buttonBackgroundColor,
            buttonText: widget.buttonText,
            backgroundColor: widget.backgroundColor,
            onButtonPressed: widget.onButtonPressed,
          )
        ),

        // 확장 컨테이너 (GoogleMap)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
          curve: Curves.easeInOut, // 애니메이션 곡선
          height: _isExpanded ? 300 : 0, // 확장 여부에 따라 높이 변경
          child: _isExpanded
          ? Container(
              // Google Map Container
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.5665, 126.9780), // 서울의 위도, 경도
                  zoom: 14,
                ),
                markers: {
                  const Marker(
                    markerId: MarkerId('example'),
                    position: LatLng(37.5665, 126.9780), // 서울
                    infoWindow: InfoWindow(title: '서울'),
                  ),
                },
              ),
            )
          : const SizedBox.shrink(),
        ),
      ],
    );
  }

     */
}