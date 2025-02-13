import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';
import 'package:legalfactfinder2025/features/files/file_list_controller.dart';


class FileActionMenu extends StatelessWidget {
  final FileData file;
  final FileListController controller = Get.find<FileListController>();

  FileActionMenu({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: 'download',
            child: Text('Download'),
          ),
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'download':
        _downloadFile(context);
        break;
      case 'rename':
        _renameFile(context);
        break;
      case 'delete':
        _deleteFile(context);
        break;
    }
  }

  void _downloadFile(BuildContext context) {
    final savePath = '/${file.workRoomId}/${file.fileName}'; // Replace with proper save path
    controller.downloadFile(file.fileName, savePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${file.fileName}...')),
    );
  }

  void _renameFile(BuildContext context) {
    TextEditingController textController = TextEditingController(text: file.fileName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'New File Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  // Call controller to rename the file
                  controller.fetchFileDataListByStoragePath(file.workRoomId); // Refresh the file list
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Renamed to $newName')),
                  );
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call controller to delete the file
                controller.fileDataList.remove(file); // Remove locally
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${file.fileName} deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
