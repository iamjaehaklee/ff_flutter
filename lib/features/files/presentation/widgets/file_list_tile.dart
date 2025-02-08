import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';

import 'package:legalfactfinder2025/features/files/presentation/file_page.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/file_action_menu.dart';

class FileListTile extends StatelessWidget {
  final FileData fileData;
  final String workRoomId;

  const FileListTile({
    Key? key,
    required this.fileData,
    required this.workRoomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Rendering file: ${fileData.fileName} for workRoomId: $workRoomId");
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        child: Icon(
          _getFileIcon(fileData.fileType),
          size: 26,
          color: _getFileIconColor(fileData.fileType),
        ),
      ),
      title: Text(
        fileData.fileName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize:
                  (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) *
                      0.9,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        fileData.description ?? 'No description available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize:
                  (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
                      0.9,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FileActionMenu(file: fileData),
      onTap: () {
        print(
            "File tapped: ${fileData.fileName} for workRoomId: $workRoomId storageKey: ${fileData.storageKey}");
        Get.to(() => FilePage(
              workRoomId: workRoomId,
              fileName: fileData.fileName,
              storageKey: fileData.storageKey,
            ));
      },
    );
  }

  IconData _getFileIcon(String fileType) {
    print("Getting icon for fileType: $fileType");
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
