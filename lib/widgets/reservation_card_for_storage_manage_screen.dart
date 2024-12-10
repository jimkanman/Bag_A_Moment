import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/models/storage_model.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';
import 'package:bag_a_moment/screens/reservation/ReservationDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:bag_a_moment/core/app_colors.dart';
import 'package:bag_a_moment/models/storage_reservation.dart';

class ReservationManageCard extends StatelessWidget {
  final StorageReservation reservation;

  const ReservationManageCard({
    super.key,
    this.reservation = const StorageReservation(),
  });

  String _formatToDateTimeString(String DateTimeString) {
    DateTime dt = DateTime.parse(DateTimeString);
    return '${dt.year}.${dt.month}.${dt.day}';
  }

  String _formatToHourMinuteString(String dateTimeString) {
    DateTime dt = DateTime.parse(dateTimeString);
    return '${dt.hour}시 ${dt.minute}분';
  }
  
  String _formatLuggageInfo(List<Luggage> luggageList) {
    List<int> counts = [0, 0, 0];
    List<String> sizes = ['소형', '중형', '대형'];
    for (var luggage in luggageList) {
      switch(luggage.type.toLowerCase()) {
        case 'bag':
          counts[0]++;
          break;
        case 'carrier':
          counts[1]++;
          break;
        case 'miscellaneous_item':
          counts[2]++;
          break;
        default:
          break;
      }
    }
    String s = '';
    for (int i = 0; i < 3; i++){
      if (counts[i] == 0) continue;
      s += '${sizes[i]} ${counts[i]}개';
      if(i < 2) s += ' ';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 사용자 / 보관소 / 주소
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자명
                    Text("${reservation.memberNickname} 님", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 4,),
                    // 보관소명
                    Text(reservation.storageName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 4,),
                    // 주소
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(reservation.storageAddress, style: const TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
                      ),
                    )
                  ],
                ),

                // 짐 정보 / 날짜 / 시간 / 금액
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 짐 정보
                    Text(_formatLuggageInfo(reservation.luggage), style: const TextStyle(fontSize: 14),),
                    // const SizedBox(height: 4,),
                    // 날짜 1 (일자)
                    Text(
                      '${_formatToDateTimeString(reservation.startDateTime)} ~ ${_formatToDateTimeString(reservation.endDateTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    // const SizedBox(height: 4,),
                    // 날짜 2 (시간)
                    Text(
                      '${_formatToHourMinuteString(reservation.endDateTime)} 까지',
                      style: TextStyle(fontSize: 10),
                    ),

                    // 결재 금액
                    Text('${reservation.paymentAmount}원 결제 완료', style: TextStyle(fontSize: 8),),
                  ],

                )
              ],
            ),
          ),

          // 예약 확인하기 버튼
          GestureDetector(
            onTap: () { },
            child: const Text("예약 확인하기", style: TextStyle(color: AppColors.textDark, fontSize: 14),)
          ),
          TextButton(
            onPressed: () {
              // TODO
              print('상세보기 클릭됨');
              print("reservation id:${reservation.id}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationDetailsScreen(reservation: reservation), // TODO storageId 전달
                ),
              );
            },
            child: const Text("예약 확인하기", style: TextStyle(color: AppColors.textDark, fontSize: 14),)
          )
        ],
      )
    );
  }
}
