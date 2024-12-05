
import 'package:bag_a_moment/models/delivery_reservation.dart';
import 'package:bag_a_moment/models/luggage.dart';

class StorageReservation {
  final int id;
  final int storageId;
  final String storageName;
  final String previewImagePath;
  final List<Luggage> luggage;
  final DeliveryReservation deliveryReservation;
  final String startDateTime;
  final String endDateTime;
  final int paymentAmount;
  final String status;

  StorageReservation({
    required this.id,
    required this.storageId,
    required this.storageName,
    required this.previewImagePath,
    required this.luggage,
    required this.deliveryReservation,
    required this.startDateTime,
    required this.endDateTime,
    required this.paymentAmount,
    required this.status,
  });

  factory StorageReservation.fromJson(Map<String, dynamic> json) {
    return StorageReservation(
      id: json['id'],
      storageId: json['storageId'],
      storageName: json['storageName'],
      previewImagePath: json['previewImagePath'],
      luggage: (json['luggage'] as List)
          .map((item) => Luggage.fromJson(item))
          .toList(),
      deliveryReservation:
      DeliveryReservation.fromJson(json['deliveryReservation']),
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      paymentAmount: json['paymentAmount'],
      status: json['status'],
    );
  }
}
