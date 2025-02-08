import 'package:file_picker/file_picker.dart';

Future<String?> pickFile() async {
  print("Opening file picker...");
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.any,
    dialogTitle: "파일을 선택하세요",
    lockParentWindow: true, // iOS 등에서 전체화면 덮는 문제 해결
  );
  if (result != null && result.files.single.path != null) {
    print("File picked: ${result.files.single.path}");
    return result.files.single.path;
  }
  print("File picker canceled.");
  return null;
}
