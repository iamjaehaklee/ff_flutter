import 'package:intl/intl.dart';

String generateTimestampedFileName(String originalFileName) {
  final timestamp = DateTime.now().millisecondsSinceEpoch; // 현재 타임스탬프 (밀리초)
  final extensionIndex = originalFileName.lastIndexOf('.'); // 확장자 위치 찾기

  if (extensionIndex != -1) {
    final name = originalFileName.substring(0, extensionIndex); // 파일명 부분
    final extension = originalFileName.substring(extensionIndex); // 확장자 부분
    return '${name}_$timestamp$extension'; // 예: "document_1706789123456.pdf"
  } else {
    return '${originalFileName}_$timestamp'; // 확장자가 없는 경우
  }
}

/// 날짜 포맷 YYYY-MM-DD HH:mm
String formatDate(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

/// ✅ 날짜 포맷팅 함수 (오늘, 어제, 같은 연도, 다른 연도 구분)
String formatMessageTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    /// 오늘이면 시각 (`HH:mm`)
    return DateFormat('HH:mm').format(dateTime);
  } else if (messageDate == today.subtract(const Duration(days: 1))) {
    /// 어제면 '어제'
    return "어제";
  } else if (messageDate.year == today.year) {
    /// 같은 연도면 `MM/dd` (예: 02/03)
    return DateFormat('MM/dd').format(dateTime);
  } else {
    /// 지난 연도면 `yyyy/MM/dd` (예: 2023/02/03)
    return DateFormat('yyyy/MM/dd').format(dateTime);
  }
}