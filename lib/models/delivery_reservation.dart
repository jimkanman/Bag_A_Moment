import 'package:bag_a_moment/models/luggage.dart';

class DeliveryReservation {
  final int id;
  final int deliveryId;
  final int storageId;
  final String deliveryArrivalDateTime;
  final List<Luggage>? luggage;
  final String storageAddress;
  final String? storagePostalCode;
  final double storageLatitude;
  final double storageLongitude;
  final String destinationAddress;
  final String? destinationPostalCode;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? distance;
  final String status;

  DeliveryReservation({
    this.id = 0,
    this.deliveryId = 0,
    this.storageId = 0,
    this.deliveryArrivalDateTime = '2024-01-01T10:00:00',
    this.luggage,
    this.storageAddress = '서울특별시 출발지 주소',
    this.storagePostalCode = '12345',
    this.storageLatitude = 37.504708,
    this.storageLongitude = 126.955936,
    this.destinationAddress = '서울특별시 흑석로 84 310관 727호',
    this.destinationPostalCode = '67890',
    this.destinationLatitude = 37.508553,
    this.destinationLongitude = 127,
    this.distance = 0.0,
    this.status = 'ON_DELIVERY',
  });

  factory DeliveryReservation.fromJson(Map<String, dynamic> json) {
    return DeliveryReservation(
      id: json['id'],
      deliveryId: json['deliveryId'],
      storageId: json['storageId'],
      deliveryArrivalDateTime: json['deliveryArrivalDateTime'],
      luggage: json['luggage'] != null
          ? (json['luggage'] as List)
          .map((item) => Luggage.fromJson(item))
          .toList()
          : [],
      storageAddress: json['storageAddress'],
      storagePostalCode: json['storagePostalCode'],
      storageLatitude: json['storageLatitude']?.toDouble(),
      storageLongitude: json['storageLongitude']?.toDouble(),
      destinationAddress: json['destinationAddress'],
      destinationPostalCode: json['destinationPostalCode'],
      destinationLatitude: json['destinationLatitude']?.toDouble(),
      destinationLongitude: json['destinationLongitude']?.toDouble(),
      distance: json['distance']?.toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryId': deliveryId,
      'storageId': storageId,
      'deliveryArrivalDateTime': deliveryArrivalDateTime,
      'luggage': luggage?.map((item) => item.toJson()).toList(),
      'storageAddress': storageAddress,
      'storagePostalCode': storagePostalCode,
      'storageLatitude': storageLatitude,
      'storageLongitude': storageLongitude,
      'destinationAddress': destinationAddress,
      'destinationPostalCode': destinationPostalCode,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'distance': distance,
      'status': status,
    };
  }

  @override
  String toString() {
    return '''
DeliveryReservation {
  id: $id,
  deliveryId: $deliveryId,
  storageId: $storageId,
  deliveryArrivalDateTime: $deliveryArrivalDateTime,
  luggage: ${luggage?.map((l) => l.toString()).join(', ') ?? 'null'},
  storageAddress: $storageAddress,
  storagePostalCode: $storagePostalCode,
  storageLatitude: $storageLatitude,
  storageLongitude: $storageLongitude,
  destinationAddress: $destinationAddress,
  destinationPostalCode: $destinationPostalCode,
  destinationLatitude: $destinationLatitude,
  destinationLongitude: $destinationLongitude,
  distance: $distance,
  status: $status
}
''';
  }
}
