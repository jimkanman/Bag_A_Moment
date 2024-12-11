import 'package:bag_a_moment/models/luggage.dart';
import 'delivery_reservation.dart';
import 'package:bag_a_moment/core/app_constants.dart';



/// 보관소 모델 (Storage.dart가 이미 있으므로 (아마 보관소 상세 페이지..?)
/// StorageModel로 이름 지음)
class StorageModel {
  final int id;
  final String name;
  final int ownerId;
  final String phoneNumber;
  final String description;
  final bool hasDeliveryService;
  final String postalCode;
  final String detailedAddress;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final int backpackPricePerHour;
  final int carrierPricePerHour;
  final int miscellaneousItemPricePerHour;
  final String termsAndConditions;
  final String status;
  final List<String> images;
  final List<String> storageOptions;

  StorageModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.phoneNumber,
    required this.description,
    required this.hasDeliveryService,
    required this.postalCode,
    required this.detailedAddress,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.backpackPricePerHour,
    required this.carrierPricePerHour,
    required this.miscellaneousItemPricePerHour,
    required this.termsAndConditions,
    required this.status,
    required this.images,
    required this.storageOptions,

  });

  factory StorageModel.fromJson(Map<String, dynamic> json) {
    try {
      return StorageModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name']?.toString() ?? '',
        ownerId: json['ownerId'] is int ? json['ownerId'] : int.tryParse(json['ownerId'].toString()) ?? 0,
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        hasDeliveryService: json['hasDeliveryService'] ?? false,
        postalCode: json['postalCode']?.toString() ?? '',
        detailedAddress: json['detailedAddress']?.toString() ?? '',
        latitude: json['latitude']?.toDouble() ?? 0.0,
        longitude: json['longitude']?.toDouble() ?? 0.0,
        openingTime: json['openingTime']?.toString() ?? '',
        closingTime: json['closingTime']?.toString() ?? '',
        backpackPricePerHour: json['backpackPricePerHour'] is int
            ? json['backpackPricePerHour']
            : int.tryParse(json['backpackPricePerHour'].toString()) ?? 0,
        carrierPricePerHour: json['carrierPricePerHour'] is int
            ? json['carrierPricePerHour']
            : int.tryParse(json['carrierPricePerHour'].toString()) ?? 0,
        miscellaneousItemPricePerHour: json['miscellaneousItemPricePerHour'] is int
            ? json['miscellaneousItemPricePerHour']
            : int.tryParse(json['miscellaneousItemPricePerHour'].toString()) ?? 0,
        termsAndConditions: json['termsAndConditions']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [],
        storageOptions: (json['storageOptions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [],
      );
    } catch (e) {
      throw Exception("Error parsing StorageModel: $e");
    }
  }
}

