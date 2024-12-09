class Luggage {
  final String type;
  final int? width;
  final int? depth;
  final int? height;

  Luggage({
    required this.type,
    required this.width,
    required this.depth,
    required this.height,
  });

  factory Luggage.fromJson(Map<String, dynamic> json) {
    return Luggage(
      type: json['type'],
      width: json['width'],
      depth: json['depth'],
      height: json['height'],
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
