import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/files/presentation/pdf_file_view_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/image_file_view_screen.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';

class FileViewLayout extends StatelessWidget {
  final String workRoomId;
  final String fileName;
  final String storageKey;
  final WorkRoomWithParticipants workRoomWithParticipants;

  const FileViewLayout({
    Key? key,
    required this.workRoomId,
    required this.fileName,
    required this.storageKey,
    required this.workRoomWithParticipants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fileExtension = fileName.split('.').last.toLowerCase();
    final bool isPdf = fileExtension == 'pdf';

    return isPdf
        ? PDFFileViewScreen(
      workRoomId: workRoomId,
      fileName: fileName,
      storageKey: storageKey,
      workRoomWithParticipants: workRoomWithParticipants,
    )
        : ImageFileViewScreen(
      workRoomId: workRoomId,
      fileName: fileName,
      storageKey: storageKey,
      workRoomWithParticipants: workRoomWithParticipants,
    );
  }
}
