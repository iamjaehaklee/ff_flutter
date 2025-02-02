import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/files/presentation/pdf_file_view_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/image_file_view_screen.dart';

class FileViewLayout extends StatelessWidget {
  final String workRoomId;
  final String fileName;

  const FileViewLayout({
    Key? key,
    required this.workRoomId,
    required this.fileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fileExtension = fileName.split('.').last.toLowerCase();
    final bool isPdf = fileExtension == 'pdf';

    return isPdf
        ? PDFFileViewScreen(workRoomId: workRoomId, fileName: fileName)
        : ImageFileViewScreen(workRoomId: workRoomId, fileName: fileName);
  }
}
