
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/luggage.dart';
import 'package:bag_a_moment/core/app_constants.dart';

class StorageReservation {
  final int id;
  final int? memberId;
  final String? memberNickname;
  final int storageId;
  final String storageName;
  final String storageAddress;
  final String previewImagePath;
  final List<Luggage> luggage;
  final DeliveryReservation? deliveryReservation;
  final String startDateTime;
  final String endDateTime;
  final int paymentAmount;
  final String status;

  StorageReservation copyWith({
    List<Luggage>? luggage,
  }) {
    return StorageReservation(
      luggage: luggage ?? this.luggage,
    );
  }

  const StorageReservation({
    this.id = 0,
    this.memberId = 0,
    this.memberNickname = "예약자",
    this.storageId = 0,
    this.storageName = "보관소",
    this.storageAddress = "서울특별시 흑석로 84 209관 519호",
    this.previewImagePath = AppConstants.DEFAULT_PREVIEW_IMAGE_PATH,
    this.luggage = const [],
    this.deliveryReservation,
    this.startDateTime = '2024-01-01T10:00:00',
    this.endDateTime = '2024-01-01T18:00:00',
    this.paymentAmount = 0,
    this.status = 'APPROVED',
  });

  factory StorageReservation.fromJson(Map<String, dynamic> json) {
    return StorageReservation(
      id: json['id'],
      memberId: json['memberId'],
      memberNickname: json['memberNickname'],
      storageId: json['storageId'],
      storageName: json['storageName'],
      luggage: json['luggage'] != null
          ? (json['luggage'] as List)
          .map((item) => Luggage.fromJson(item))
          .toList()
          : [],
      deliveryReservation:
        json['deliveryReservation'] != null
            ? DeliveryReservation.fromJson(json['deliveryReservation'])
            : null,
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      paymentAmount: json['paymentAmount'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return '''
StorageReservation {
  id: $id,
  memberId: $memberId,
  memberNickname: $memberNickname,
  storageId: $storageId,
  storageName: $storageName,
  storageAddress: $storageAddress,
  previewImagePath: $previewImagePath,
  luggage: ${luggage.map((l) => l.toString()).join(', ')},
  deliveryReservation: ${deliveryReservation?.toString() ?? 'null'},
  startDateTime: $startDateTime,
  endDateTime: $endDateTime,
  paymentAmount: $paymentAmount,
  status: $status
}
''';
  }
}
