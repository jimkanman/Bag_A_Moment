class Luggage {
  final String type;
  final int? width;
  final int? depth;
  final int? height;
  final String? imagePath;

  const Luggage({
    required this.type,
    required this.width,
    required this.depth,
    required this.height,
    this.imagePath
  });

  factory Luggage.fromJson(Map<String, dynamic> json) {
    return Luggage(
      type: json['type'],
      width: json['width'],
      depth: json['depth'],
      height: json['height'],
      imagePath: json['imagePath']??null,
    );
  }
  Luggage copyWith({
    String? type,
    int? width,
    int? depth,
    int? height,
    String? imagePath,
  }) {
    return Luggage(
      type: type ?? this.type,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      height: height ?? this.height,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'width': width,
      'depth': depth,
      'height': height,
    };
  }
}
