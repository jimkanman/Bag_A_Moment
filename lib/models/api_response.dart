
class ApiResponse<T> {
  final bool isSuccess;
  final int code;
  final String message;
  final List<T> data;

  ApiResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
    );
  }
}
