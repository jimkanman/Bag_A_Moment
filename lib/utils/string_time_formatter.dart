
class StringTimeFormatter {
  static String? formatTime(String? isoDateTime) {
    if (isoDateTime == null) return null;
    try {
      // ISO 8601 문자열을 DateTime 객체로 변환
      DateTime dateTime = DateTime.parse(isoDateTime);

      // 시간(HH:mm) 형식으로 변환
      String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

      return formattedTime;
    } catch (e) {
      print("Invalid date format: $isoDateTime");
      return ""; // 잘못된 입력일 경우 빈 문자열 반환
    }
  }
}