// lib/folder_tree_utils.dart
import 'package:legalfactfinder2025/features/files/data/folder_model.dart';

class FolderNode {
  final String id;
  final String name;
  final String path;
  final List<FolderNode> children;
  bool isExpanded;

  FolderNode({
    required this.id,
    required this.name,
    required this.path,
    this.children = const [],
    this.isExpanded = false,
  });
}

// 하위 노드 중에서 선택된 폴더를 찾아 isExpanded를 true로 설정하는 헬퍼 함수
void expandSelectedNode(List<FolderNode> nodes, String selectedPath) {
  for (var node in nodes) {
    if (node.path == selectedPath) {
      node.isExpanded = true;
      return;
    }
    expandSelectedNode(node.children, selectedPath);
  }
}

// 폴더 목록을 트리 구조로 변환
List<FolderNode> buildFolderTree(List<Folder> folders) {
  final Map<String, FolderNode> nodeMap = {};
  final List<FolderNode> rootNodes = [];

  // 최상위 폴더 노드 추가 (항상 펼쳐진 상태로)
  final rootNode = FolderNode(
    id: 'root',
    name: '최상위 폴더',
    path: '',
    children: [],
    isExpanded: true, // 최상위 폴더는 항상 펼쳐진 상태
  );
  nodeMap[''] = rootNode;
  rootNodes.add(rootNode);

  // 모든 폴더를 노드로 변환
  for (var folder in folders) {
    final pathParts = folder.folderPath.split('/');
    final node = FolderNode(
      id: folder.id,
      name: folder.folderName ?? pathParts.last,
      path: folder.folderPath,
      children: [],
    );
    nodeMap[folder.folderPath] = node;
  }

  // 부모-자식 관계 설정
  for (var folder in folders) {
    final pathParts =
        folder.folderPath.split('/').where((part) => part.isNotEmpty).toList();

    if (pathParts.length == 1) {
      // 최상위 폴더는 root 노드의 자식으로 추가
      if (!rootNode.children.any((child) => child.path == folder.folderPath)) {
        rootNode.children.add(nodeMap[folder.folderPath]!);
      }
    } else {
      // 하위 폴더인 경우
      final parentPath = pathParts.sublist(0, pathParts.length - 1).join('/');
      final parentNode = nodeMap[parentPath];
      if (parentNode != null) {
        if (!parentNode.children
            .any((child) => child.path == folder.folderPath)) {
          parentNode.children.add(nodeMap[folder.folderPath]!);
        }
      }
    }
  }

  Folder? previewFolder;
  try {
    previewFolder = folders.firstWhere((f) => f.id == 'preview');
  } catch (e) {
    previewFolder = null;
  }

  if (previewFolder != null) {
    if (previewFolder.parentFolderId == null) {
      if (!rootNode.children
          .any((child) => child.path == previewFolder!.folderPath)) {
        rootNode.children.add(nodeMap[previewFolder.folderPath]!);
      }
    } else {
      final parentNode = nodeMap[previewFolder.parentFolderId];
      if (parentNode != null) {
        parentNode.children.add(nodeMap[previewFolder.folderPath]!);
      }
    }
  }

  return rootNodes;
}
