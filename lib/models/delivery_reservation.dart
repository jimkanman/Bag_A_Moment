import 'package:bag_a_moment/models/luggage.dart';

class DeliveryReservation {
  final List<Luggage> luggage;
  final String startDateTime;
  final String endDateTime;

  DeliveryReservation({
    required this.luggage,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory DeliveryReservation.fromJson(Map<String, dynamic> json) {
    return DeliveryReservation(
      luggage: (json['luggage'] as List)
          .map((item) => Luggage.fromJson(item))
          .toList(),
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
    );
  }
}
