
class Location {
  final int deliveryId;
  double? latitude;
  double? longitude;

  Location({
    required this.deliveryId,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      deliveryId: json['deliveryId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}