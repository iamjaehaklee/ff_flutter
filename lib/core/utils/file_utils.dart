/// 주어진 전체 경로 문자열에서 파일명을 제외한 디렉토리 경로만 반환합니다.
/// 예: "folder/subfolder/file.txt" -> "folder/subfolder"
String extractDirectoryPath(String fullPath) {
  // '/'와 '\' 둘 다 지원하여 마지막 경로 구분자를 찾습니다.
  final lastSlashIndex = fullPath.lastIndexOf('/');
  final lastBackslashIndex = fullPath.lastIndexOf('\\');
  final lastSeparatorIndex = lastSlashIndex > lastBackslashIndex ? lastSlashIndex : lastBackslashIndex;

  if (lastSeparatorIndex == -1) {
    // 경로 구분자가 없으면, 디렉토리 경로가 없다고 판단합니다.
    return '';
  }

  // 디렉토리 경로를 반환 (파일명 제외)
  return fullPath.substring(0, lastSeparatorIndex);
}


/// 파일명에서 마지막 점(.)을 찾아서, 파일 확장자 구분 기호를 변경하는 함수입니다.
/// 만약 파일명에 점이 없다면 원래 파일명을 그대로 반환합니다.
///
/// [fileName] : 원본 파일명 (예: "example.txt" 또는 "archive.tar.gz")
/// [newSeparator] : 대체할 문자 (예: '_' 또는 '-' 등)
String replaceFileExtensionSeparator(String fileName, {String newSeparator = '_'}) {
  final lastDotIndex = fileName.lastIndexOf('.');
  if (lastDotIndex == -1) {
    // 파일명에 점이 없는 경우, 그대로 반환
    return fileName;
  }
  // 파일명 부분과 확장자 부분을 분리하여 대체 문자로 연결
  return fileName.substring(0, lastDotIndex) + newSeparator + fileName.substring(lastDotIndex + 1);
}