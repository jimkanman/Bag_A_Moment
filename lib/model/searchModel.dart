class searchModel {
  final int id;
  final String name;
  final String previewImagePath;
  final String detailedAddress;
  final double latitude;
  final double longitude;
  final double distance;

  searchModel({
    required this.id,
    required this.name,
    required this.previewImagePath,
    required this.detailedAddress,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory searchModel.fromJson(Map<String, dynamic> json) {
    return searchModel(
      id: json['id'],
      name: json['name'],
      previewImagePath: json['previewImagePath'],
      detailedAddress: json['detailedAddress'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      distance: json['distance'],
    );
  }
}
