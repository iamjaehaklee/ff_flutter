// lib/create_folder_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/folder_model.dart';
import 'package:legalfactfinder2025/features/files/folders_controller.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'folder_tree_utils.dart';

void showCreateFolderDialog(BuildContext context, String workRoomId) {
  final folderController = Get.find<FoldersController>();
  final textController = TextEditingController(text: '새 폴더');
  final selectedFolderPath = ''.obs;
  final folderName = '새 폴더'.obs;

  // 새 폴더의 전체 경로를 계산하는 함수 (선택된 경로와 폴더 이름 사용)
  String getFullPath() {
    final currentPath = selectedFolderPath.value;
    final newFolderName = folderName.value;
    return currentPath.isEmpty ? newFolderName : '$currentPath/$newFolderName';
  }

  // 모든 노드를 펼치는 함수
  void expandAllNodes(List<FolderNode> nodes) {
    for (var node in nodes) {
      node.isExpanded = true;
      if (node.children.isNotEmpty) {
        expandAllNodes(node.children);
      }
    }
  }

  final treeController = TreeController<FolderNode>(
    roots: buildFolderTree([
      ...folderController.currentFolders,
    ]),
    childrenProvider: (FolderNode node) => node.children,
  );

  // tree를 갱신하는 함수
  void updateTree() {
    final updatedRoots = buildFolderTree([
      ...folderController.currentFolders,
    ]);

    // 모든 폴더 노드를 펼침
    expandAllNodes(updatedRoots);

    // TreeController 업데이트
    treeController.roots = updatedRoots;

    // 최상위 폴더가 항상 펼쳐지도록 보장
    if (updatedRoots.isNotEmpty && updatedRoots.first.id == 'root') {
      treeController.toggleExpansion(updatedRoots.first);
    }
  }

  // 텍스트 필드 내용 변경 시 folderName 업데이트 및 tree 갱신
  textController.addListener(() {
    folderName.value = textController.text;
    updateTree();
  });
  ever(selectedFolderPath, (_) => updateTree());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('새 폴더 만들기'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: '폴더 이름',
                  hintText: '새 폴더 이름을 입력하세요',
                ),
              ),
              const SizedBox(height: 8),
              // 생성될 위치 텍스트 (folderName 및 선택된 경로 반영)
              Obx(() => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '생성될 위치: 최상위 폴더/${getFullPath()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '생성 위치 선택:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<Folder>>(
                          future: folderController.listFolders(workRoomId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('오류: ${snapshot.error}'));
                            }
                            final folders = snapshot.data ?? [];
                            // 선택된 폴더가 리스트에 없으면 dummy 폴더 추가
                            final List<Folder> folderList = List.from(folders);
                            if (selectedFolderPath.value.isNotEmpty &&
                                !folderList.any((f) =>
                                    f.folderPath == selectedFolderPath.value)) {
                              folderList.add(Folder(
                                id: selectedFolderPath.value,
                                folderPath: selectedFolderPath.value,
                                folderName:
                                    selectedFolderPath.value.split('/').last,
                                workRoomId: workRoomId,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                createdBy:
                                    Get.find<AuthController>().getUserId() ??
                                        '',
                                parentFolderId: null,
                              ));
                            }

                            final rootNodes = buildFolderTree(folderList);
                            expandAllNodes(rootNodes);
                            treeController.roots = rootNodes;

                            return TreeView<FolderNode>(
                              treeController: treeController,
                              nodeBuilder: (BuildContext context,
                                  TreeEntry<FolderNode> entry) {
                                return TreeIndentation(
                                  entry: entry,
                                  child: Obx(() => ListTile(
                                        leading: Icon(
                                          entry.node.id == 'root'
                                              ? Icons.home_filled
                                              : entry.node.path ==
                                                      selectedFolderPath.value
                                                  ? Icons.folder_open
                                                  : Icons.folder,
                                          color: entry.node.path ==
                                                      selectedFolderPath
                                                          .value ||
                                                  (entry.node.id == 'root' &&
                                                      selectedFolderPath
                                                          .value.isEmpty)
                                              ? Colors.blue
                                              : null,
                                        ),
                                        title: Row(
                                          children: [

                                            const SizedBox(width: 4),
                                            Text(
                                              entry.node.id == 'root'
                                                  ? '최상위 폴더'
                                                  : entry.node.name,
                                              style: (entry.node.id == 'root' &&
                                                          selectedFolderPath
                                                              .value.isEmpty) ||
                                                      entry.node.path ==
                                                          selectedFolderPath
                                                              .value
                                                  ? const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        selected: entry.node.path ==
                                                selectedFolderPath.value ||
                                            (entry.node.id == 'root' &&
                                                selectedFolderPath
                                                    .value.isEmpty),
                                        selectedTileColor:
                                            Colors.blue.withOpacity(0.1),
                                        onTap: () {
                                          selectedFolderPath.value =
                                              entry.node.id == 'root'
                                                  ? ''
                                                  : entry.node.path;
                                          updateTree();
                                        },
                                        dense: true,
                                      )),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          Obx(() => ElevatedButton(
                onPressed: folderController.isLoading.value
                    ? null
                    : () {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          if (folderName.value.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('폴더 이름을 입력해주세요')),
                            );
                            return;
                          }
                          final success = await folderController.createFolder(
                            workRoomId,
                            folderName.value,
                          );
                          if (success) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                child: folderController.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('만들기'),
              )),
        ],
      );
    },
  );
}
