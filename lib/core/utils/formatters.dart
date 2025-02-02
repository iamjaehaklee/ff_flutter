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