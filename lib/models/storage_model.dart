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
  final String notice;
  final bool hasDeliveryService;
  final String postalCode;
  final String detailedAddress;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final int backpackPricePerHour;
  final int carrierPricePerHour;
  final int miscellaneousItemPricePerHour;
  final String termsAndConditions;
  final List<String> images;
  final List<String> storageOptions;
  final String status; // PENDING, REJECTED, APPROVED

  /// 생성자
  StorageModel({
    this.id = 0,
    this.name = "기본 보관소",
    this.ownerId = 0,
    this.phoneNumber = "010-0000-0000",
    this.description = "기본 설명",
    this.notice = "기본 공지",
    this.hasDeliveryService = false,
    this.postalCode = "00000",
    this.detailedAddress = "서울특별시 흑석로 84 208관",
    this.latitude = 37.504708,
    this.longitude = 126.955936,
    this.openingTime = "09:00",
    this.closingTime = "18:00",
    this.isOpen = true,
    this.backpackPricePerHour = 0,
    this.carrierPricePerHour = 0,
    this.miscellaneousItemPricePerHour = 0,
    this.termsAndConditions = "기본 약관",
    this.images = const [AppConstants.DEFAULT_PREVIEW_IMAGE_PATH],
    this.storageOptions = const [],
    this.status = "PENDING", // 기본값
  });

  /// JSON 데이터를 StorageModel 객체로 변환
  factory StorageModel.fromJson(Map<String, dynamic> json) {
    return StorageModel(
      id: json['id'],
      name: json['name'],
      ownerId: json['ownerId'],
      phoneNumber: json['phoneNumber'],
      description: json['description'],
      notice: json['notice'],
      hasDeliveryService: json['hasDeliveryService'],
      postalCode: json['postalCode'],
      detailedAddress: json['detailedAddress'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isOpen: json['isOpen'],
      backpackPricePerHour: json['backpackPricePerHour'],
      carrierPricePerHour: json['carrierPricePerHour'],
      miscellaneousItemPricePerHour: json['miscellaneousItemPricePerHour'],
      termsAndConditions: json['termsAndConditions'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      storageOptions: json['storageOptions'] != null
          ? List<String>.from(json['storageOptions'])
          : [],
      status: json['status'],
    );
  }

  /// StorageModel 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'phoneNumber': phoneNumber,
      'description': description,
      'notice': notice,
      'hasDeliveryService': hasDeliveryService,
      'postalCode': postalCode,
      'detailedAddress': detailedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isOpen': isOpen,
      'backpackPricePerHour': backpackPricePerHour,
      'carrierPricePerHour': carrierPricePerHour,
      'miscellaneousItemPricePerHour': miscellaneousItemPricePerHour,
      'termsAndConditions': termsAndConditions,
      'images': images,
      'storageOptions': storageOptions,
      'status': status,
    };
  }
}
