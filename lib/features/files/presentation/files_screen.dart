import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';
import 'package:legalfactfinder2025/features/files/folders_controller.dart';
import 'package:legalfactfinder2025/features/files/file_list_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/create_folder_dialog.dart';
import 'package:legalfactfinder2025/features/files/data/folder_model.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/file_list_tile.dart';
import 'package:path/path.dart' as p;

class FilesScreen extends StatelessWidget {
  final String workRoomId;

  FilesScreen({required this.workRoomId});

  @override
  Widget build(BuildContext context) {
    final foldersController = Get.find<FoldersController>();
    final fileListController = Get.find<FileListController>();
    final currentPath = ''.obs;

    if (foldersController.currentFolders.isEmpty) {
      foldersController.listFolders(workRoomId);
    }
    if (fileListController.fileDataList.isEmpty) {
      fileListController.fetchFileDataListByStoragePath(workRoomId);
    }

    void navigateToParent() {
      if (currentPath.value.isEmpty) return;
      final pathParts = currentPath.value.split('/');
      if (pathParts.length > 1) {
        currentPath.value =
            pathParts.sublist(0, pathParts.length - 1).join('/');
      } else {
        currentPath.value = '';
      }
    }

    void showAddBottomSheet() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.create_new_folder,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('새 폴더 만들기'),
                  onTap: () {
                    Navigator.pop(context);
                    showCreateFolderDialog(context, workRoomId);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.upload_file,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('파일 업로드'),
                  onTap: () async {
                    Navigator.pop(context);
                    // 파일 선택하기
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      PlatformFile pickedFile = result.files.first;
                      if (pickedFile.path != null) {
                        // 필요 시 사용자에게 파일 설명을 입력받을 수 있음.
                        String description = '';
                        final uploaderId =
                            Get.find<AuthController>().getUserId() ?? '';
                        final fileListController =
                            Get.find<FileListController>();

                        // 선택한 파일의 경로와 이름, 설명, workRoomId, uploaderId를 전달하여 업로드 호출
                        await fileListController
                            .uploadFileToStorageAndPutFileData(
                          pickedFile.path!,
                          pickedFile.name,
                          description,
                          workRoomId,
                          uploaderId,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Obx(() => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (currentPath.value.isNotEmpty)
                        TextButton.icon(
                          onPressed: navigateToParent,
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('상위 폴더로'),
                        ),
                      if (currentPath.value.isNotEmpty)
                        const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '현재 위치: ${currentPath.value.isEmpty ? '최상위 폴더' : currentPath.value}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Expanded(
              child: Obx(() {
                final folders = foldersController.currentFolders;
                final files = fileListController.fileDataList;

                final currentFolders = folders.where((folder) {
                  if (currentPath.value.isEmpty) {
                    return !folder.folderPath.contains('/');
                  }
                  return folder.folderPath.startsWith(currentPath.value) &&
                      folder.folderPath.split('/').length ==
                          currentPath.value.split('/').length + 1;
                }).toList();

// 현재 폴더 경로 계산
                final currentFolderPath = currentPath.value.isEmpty
                    ? workRoomId
                    : '$workRoomId/${currentPath.value}';

// 파일의 storageKey에서 디렉토리 부분을 추출하여 비교
                final currentFiles = files.where((file) {
                  final fileDir = p.dirname(file.storageKey);
                  print("File storageKey: ${file.storageKey} => Dir: $fileDir");
                  return fileDir == currentFolderPath;
                }).toList();

                return ListView.builder(
                  itemCount: currentFolders.length + currentFiles.length,
                  itemBuilder: (context, index) {
                    if (index < currentFolders.length) {
                      final folder = currentFolders[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        leading: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.folder,
                            size: 26,
                            color: Colors.amber,
                          ),
                        ),
                        title: Text(
                          folder.folderName ??
                              folder.folderPath.split('/').last,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.fontSize ??
                                            16) *
                                        0.9,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '폴더',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: (Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.fontSize ??
                                            14) *
                                        0.9,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('이름 변경'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text('삭제'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'rename') {
                                final controller = TextEditingController(
                                    text: folder.folderName ??
                                        folder.folderPath.split('/').last);
                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('폴더 이름 변경'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        labelText: '새 폴더 이름',
                                      ),
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                            context, controller.text),
                                        child: const Text('변경'),
                                      ),
                                    ],
                                  ),
                                );

                                if (newName != null &&
                                    newName.isNotEmpty &&
                                    newName !=
                                        (folder.folderName ??
                                            folder.folderPath
                                                .split('/')
                                                .last)) {
                                  final success = await foldersController
                                      .renameFolder(folder.id!, newName);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('폴더 이름이 변경되었습니다.')),
                                    );
                                  }
                                }
                              } else if (value == 'delete') {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('폴더 삭제'),
                                    content: const Text(
                                        '이 폴더를 삭제하시겠습니까?\n폴더 내에 파일이나 하위 폴더가 있으면 삭제할 수 없습니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  final success = await foldersController
                                      .deleteFolder(workRoomId,folder.id!);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('폴더가 삭제되었습니다.')),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(foldersController
                                            .errorMessage.value),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        onTap: () {
                          currentPath.value = folder.folderPath;
                        },
                      );
                    } else {
                      final fileData =
                          currentFiles[index - currentFolders.length];
                      return FileListTile(
                        workRoomId: workRoomId,
                        fileData: fileData,
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: showAddBottomSheet,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
