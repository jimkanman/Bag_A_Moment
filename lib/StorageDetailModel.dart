class StorageDetail {
  final int id;
  final String name;
  final int ownerId;
  final String phoneNumber;
  final String? description;
  final String? notice;
  final bool? hasDeliveryService;
  final String postalCode;
  final String detailedAddress;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final int backpackPricePerHour;
  final int carrierPricePerHour;
  final int miscellaneousItemPricePerHour;
  final String? termsAndConditions;
  final List<String>? images;
  final List<String>? storageOptions;

  StorageDetail({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.phoneNumber,
    this.hasDeliveryService,
    this.description,
    this.notice,
    required this.postalCode,
    required this.detailedAddress,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.backpackPricePerHour,
    required this.carrierPricePerHour,
    required this.miscellaneousItemPricePerHour,
    this.termsAndConditions,
    required this.images,
    this.storageOptions,
  });

  factory StorageDetail.fromJson(Map<String, dynamic> json) {
    return StorageDetail(
      id: json['id'],
      name: json['name'],
      ownerId: json['ownerId'],
      phoneNumber: json['phoneNumber'],
      description: json['description'],
      notice: json['notice'],
      hasDeliveryService: json['hasDeliveryService'],
      postalCode: json['postalCode'],
      detailedAddress: json['detailedAddress'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      backpackPricePerHour: json['backpackPricePerHour'],
      carrierPricePerHour: json['carrierPricePerHour'],
      miscellaneousItemPricePerHour: json['miscellaneousItemPricePerHour'],
      termsAndConditions: json['termsAndConditions'],
      images: List<String>.from(json['images']),
      storageOptions: List<String>.from(json['storageOptions']),
    );
  }

  get distance => null;

  get address => null;

  //get distance => null;

 // get address => null;
}
