import 'package:bag_a_moment/core/app_constants.dart';
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/widgets/rectangular_elevated_button.dart';
import 'package:bag_a_moment/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/map_controller_notifier.dart';



class ExpandableReservationCard extends StatefulWidget {
  final List<Luggage> luggage;
  final String previewImagePath;
  final String storageName;
  final String pickupTime;
  final Color buttonBackgroundColor;
  final Text buttonText;
  final Color backgroundColor;
  final VoidCallback? onButtonPressed;
  final DeliveryReservation deliveryReservation;
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
    required this.deliveryReservation,
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
  final Set<Marker> _markers = {};

  Widget determineElevatedButton(String? status) {
    Text buttonText;
    Color backgroundColor;

    switch(status?.toUpperCase()) {
      case "PENDING":
        buttonText = const Text("배송 대기", style: TextStyle(color: AppColors.textDark, fontSize: 10),);
        backgroundColor = AppColors.backgroundLight;
        break;
      case "ASSIGNED":
        buttonText = const Text("배정 완료", style: TextStyle(color: AppColors.textDark, fontSize: 10));
        backgroundColor = AppColors.backgroundLight;
        break;
      case "ON_DELIVERY":
        buttonText = const Text("배송 중", style: TextStyle(color: AppColors.textLight, fontSize: 10));
        backgroundColor = AppColors.textDark;
        break;
      case "COMPLETED":
        buttonText = const Text("배송 완료", style: TextStyle(color: Colors.white, fontSize: 10));
        backgroundColor = AppColors.backgroundDarkBlack;
        break;
      default:
        buttonText = const Text("배송 대기", style: TextStyle(color: AppColors.textDark, fontSize: 10));
        backgroundColor = AppColors.backgroundLight;
        print("DELIVERYRESERVATIONCARD: INVALID STATUS '$status'");

    }
    return RectangularElevatedButton(
      borderRadius: 4,
      onPressed: widget.onButtonPressed,
      backgroundColor: backgroundColor,
      child: buttonText,
    );
  }


  Color determineDeliveryReservationCardButtonColor(String? status) {
    switch(status?.toUpperCase()) {
      case "PENDING":
        return AppColors.backgroundLight;
      case "ASSIGNED":
        return AppColors.backgroundLight;
      case "ON_DELIVERY":
        return AppColors.primary;
      case "COMPLETED":
        return AppColors.backgroundDarkBlack;
      default:
        print("DELIVERYRESERVATIONCARD: INVALID STATUS '$status'");
        return AppColors.backgroundGray;
    }
  }

  Text determineDeliveryReservationCardText(String? status) {
    const TextStyle(color: AppColors.textDark, fontSize: 10);

    switch(status?.toUpperCase()) {
      case "PENDING": return const Text("배송 대기", style: TextStyle(color: AppColors.textDark, fontSize: 10),);
      case "ASSIGNED": return const Text("배정 완료", style: TextStyle(color: AppColors.textDark, fontSize: 10),);
      case "ON_DELIVERY": return const Text("배송 중", style: TextStyle(color: AppColors.textLight, fontSize: 10),);
      case "COMPLETE": return const Text("배송 완료", style: TextStyle(color: AppColors.textLight, fontSize: 10),);
      default: return const Text("배송 대기", style: TextStyle(color: AppColors.textDark, fontSize: 10),);
    }
  }

  Widget DeliveryStatusString(String status) {
    switch(status.toUpperCase()){
      case 'ON_DELIVERY':
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("배송맨", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold ),),
            Text("이 목적지를 향해 ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
            Text("이동", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold ),),
            Text("하고 있어요", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),)
          ],
        );
      case 'COMPLETE':
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("배송이", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
            Text("완료", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold ),),
            Text("되었어요", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),)
          ],
        );
      case 'PENDING':
      default:
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("보관소에서 보관 중이에요", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
          ],
        );
    }

  }

  Future<void> _addCustomMarker() async {
    final BitmapDescriptor storageRed = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // 이미지 크기 조정
      'assets/images/red_box_icon.png', // assets 경로
    );
    final BitmapDescriptor storageGreen = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // 이미지 크기 조정
      'assets/images/green_box_icon.png', // assets 경로
    );

    final marks = [
      if(widget.deliveryLatitude != null && widget.deliveryLongitude != null)
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(
              widget.deliveryLatitude!,
              widget.deliveryLongitude!),
          infoWindow: const InfoWindow(title: '배송맨'),
        ),
      Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
              widget.deliveryReservation.destinationLatitude ?? 37.5665,
              widget.deliveryReservation.destinationLongitude ?? 126.9780),
          infoWindow: const InfoWindow(title: '목적지'),
          icon: storageRed
      ),
      Marker(
          markerId: const MarkerId('storage'),
          position: LatLng(
              widget.deliveryReservation.storageLatitude,
              widget.deliveryReservation.storageLongitude),
          infoWindow: const InfoWindow(title: '배송지'),
          icon: storageGreen
      )
    ];
    print("ADDING MARKERS :");
    for(var marker in marks) {
      print(marker);
    }
    print("ADDING...");

    setState(() {
      _markers.addAll(
        marks
      );
    });
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    print("DISPONSE RESERVATION CARD");
    // Provider에서 컨트롤러 제거
    context.read<MapControllerProvider>().removeController(widget.deliveryReservation.deliveryId);
    // GoogleMapController 리소스 정리
    _mapController.dispose();

    super.dispose();
  }

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
        height: _isExpanded ? 400 : 150, // 확장 여부에 따라 높이 조절
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
                  Flexible(
                    flex: 3,
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 24.0, color: AppColors.textDark),
                        const SizedBox(width: 4.0),
                        Text(
                          '${widget.luggage.length}개',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 가운데 이미지 + 보관소 정보
                  Flexible(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.previewImagePath,
                            width: 96.0,
                            height: 70,
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
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 오른쪽 텍스트 및 버튼 (픽업 예정 시간 / 연장 요청 등)
                  Flexible(
                    flex: 7,
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
                        '${DateFormat('MM').format(DateTime.parse(widget.deliveryReservation.deliveryArrivalDateTime))}월 ${DateTime.parse(widget.deliveryReservation.deliveryArrivalDateTime).day}일 ${widget.pickupTime}',
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 28,
                              width: double.infinity,
                              child: determineElevatedButton(widget.deliveryReservation.status)
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

                     // 보관소에 보관 중이에요 / 배송맨이 이동 중이에요 / ...
                     Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DeliveryStatusString(widget.deliveryReservation!.status)
                      ),

                      // GOOGLE MAP
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            color: Colors.grey[200],
                          ),
                          child: GoogleMap(
                            // 맵 생성 완료 후
                            onMapCreated: (controller) {
                              // 마커 생성
                              _addCustomMarker();
                              // 컨트롤러 할당
                              _mapController = controller;
                              // Provider에 컨트롤러 저장
                              context.read<MapControllerProvider>().setController(widget.deliveryReservation.deliveryId, controller);
                              if(widget.deliveryLatitude != null && widget.deliveryLongitude != null) {
                                // 시작 위치 주어진 경우 해당 위치로 이동
                                controller.animateCamera(CameraUpdate.newLatLng(LatLng(widget.deliveryLatitude!, widget.deliveryLongitude!)));
                              } else {
                                // 시작 위치 주어지지 않은 경우 (= 배송 시작이 아닌 경우) 보관소 위치를 보여줌
                                controller.animateCamera(CameraUpdate.newLatLng(LatLng(widget.deliveryReservation.storageLatitude, widget.deliveryReservation!.storageLongitude)));
                              }
                              ExpandableReservationCard.googleMapControllers[widget.deliveryReservation.deliveryId] = controller;
                            },
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(37.5665, 126.9780), // 서울
                              zoom: 14,
                            ),
                            markers: _markers,
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
}
