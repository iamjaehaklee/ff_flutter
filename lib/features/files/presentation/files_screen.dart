import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/files/file_list_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_page.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/file_action_menu.dart';

class FilesScreen extends StatelessWidget {
  final String workRoomId;
  final FileListController controller = Get.put(FileListController());

  FilesScreen({Key? key, required this.workRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building FilesScreen UI inside TabView for workRoomId: $workRoomId");

    // Load files for the given workRoomId when the screen opens
    controller.fetchFiles(workRoomId);

    return Stack(
      children: [
        Obx(() {
          print(
              "Rebuilding UI based on controller state for workRoomId: $workRoomId");

          if (controller.isLoading.value) {
            print("Files are loading for workRoomId: $workRoomId");
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            print("Error: ${controller.errorMessage.value}");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text(controller.errorMessage.value),
                    actions: [
                      TextButton(
                        onPressed: () {
                          controller.errorMessage.value = '';
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            });
          }

          if (controller.files.isEmpty) {
            print("No files available for workRoomId: $workRoomId");
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No files uploaded yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          print(
              "Loaded ${controller.files.length} files for workRoomId: $workRoomId");

          return ListView.separated(
            itemCount: controller.files.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final file = controller.files[index];
              print(
                  "Rendering file: ${file.fileName} for workRoomId: $workRoomId");
              return ListTile(
                leading: Icon(
                  _getFileIcon(file.fileType),
                  size: 40,
                ),
                title: Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  file.description ?? 'No description available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: FileActionMenu(file: file),
                onTap: () {
                  print(
                      "File tapped: ${file.fileName} for workRoomId: ${workRoomId} storageKey: ${file.storageKey}");
                  Get.to(() => FilePage(
                        workRoomId: workRoomId,
                        fileName: file.fileName,
                        storageKey: file.storageKey,
                      ));
                },
              );
            },
          );
        }),

        /// FAB를 항상 하단에 고정
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () async {
              AuthController authController = Get.find<AuthController>();
              String? myUserId = authController.getUserId();
              if (myUserId == null) {
                Get.toNamed('/login');
                return;
              }
              print("FloatingActionButton pressed for workRoomId: $workRoomId");
              final filePath = await _pickFile();
              if (filePath != null) {
                print("File selected: $filePath for workRoomId: $workRoomId");
                controller.uploadFile(
                  filePath,
                  filePath.split('/').last, // 파일 이름 추출
                  'Sample description', // 설명 (사용자 입력 가능)
                  workRoomId, // 동적으로 workRoomId 사용
                 myUserId, // 실제 업로더 ID로 변경 필요
                );
              } else {
                print("No file selected for workRoomId: $workRoomId");
              }
            },
            child: const Icon(Icons.upload),
          ),
        ),
      ],
    );
  }

  // 파일 선택 메서드
  Future<String?> _pickFile() async {
    print("Opening file picker...");
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print("File picked: ${result.files.single.path}");
      return result.files.single.path;
    }
    print("File picker canceled.");
    return null;
  }

  // 파일 유형에 따라 아이콘 선택
  IconData _getFileIcon(String fileType) {
    print("Getting icon for fileType: $fileType");
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'mov':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }
}
