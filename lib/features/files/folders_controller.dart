import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/folder_model.dart';
import 'package:legalfactfinder2025/features/files/data/folders_repository.dart';

class FoldersController extends GetxController {
  final FoldersRepository _repository;
  final RxString currentPath = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Folder> currentFolders = <Folder>[].obs;

  FoldersController([FoldersRepository? repository])
      : _repository = repository ?? FoldersRepository();

  /// 폴더 생성
  Future<bool> createFolder(String workRoomId, String folderName) async {
    try {
      print("[FoldersController] createFolder: Starting folder creation");
      print(
          "[FoldersController] createFolder: workRoomId=$workRoomId, folderName=$folderName, currentPath=${currentPath.value}");

      isLoading(true);
      errorMessage('');

      // 폴더가 이미 존재하는지 확인
      final fullPath =
          currentPath.isEmpty ? folderName : '${currentPath.value}/$folderName';
      print(
          "[FoldersController] createFolder: Checking if folder exists at path: $fullPath");

      final exists = await _repository.folderExists(workRoomId, fullPath);
      if (exists) {
        print("[FoldersController] createFolder: Folder already exists");
        errorMessage('폴더가 이미 존재합니다.');
        return false;
      }

      // 폴더 생성
      print("[FoldersController] createFolder: Creating new folder");
      await _repository.createFolder(workRoomId, currentPath.value, folderName);

      // 현재 폴더 목록 새로고침
      await refreshFolders(workRoomId);

      print("[FoldersController] createFolder: Folder created successfully");
      return true;
    } catch (e) {
      print("[FoldersController] createFolder: Error occurred: $e");
      errorMessage('폴더 생성 중 오류가 발생했습니다.');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// 현재 경로 설정
  void setCurrentPath(String path) {
    print("[FoldersController] setCurrentPath: Setting path to: $path");
    currentPath(path);
  }

  /// 상위 폴더로 이동
  void navigateUp() {
    print(
        "[FoldersController] navigateUp: Current path before=${currentPath.value}");
    if (currentPath.isEmpty) return;

    final parts = currentPath.value.split('/');
    if (parts.length > 1) {
      // 마지막 부분을 제외한 경로로 설정
      currentPath(parts.sublist(0, parts.length - 1).join('/'));
    } else {
      // 최상위 경로로 이동
      currentPath('');
    }
    print("[FoldersController] navigateUp: New path=${currentPath.value}");
  }

  /// 특정 폴더로 이동
  void navigateToFolder(String folderName) {
    print(
        "[FoldersController] navigateToFolder: Current path=${currentPath.value}, target folder=$folderName");
    if (currentPath.isEmpty) {
      currentPath(folderName);
    } else {
      currentPath('${currentPath.value}/$folderName');
    }
    print(
        "[FoldersController] navigateToFolder: New path=${currentPath.value}");
  }

  /// 현재 경로의 폴더 목록 새로고침
  Future<void> refreshFolders(String workRoomId) async {
    try {
      print("[FoldersController] refreshFolders: Refreshing folders");
      print(
          "[FoldersController] refreshFolders: workRoomId=$workRoomId, currentPath=${currentPath.value}");

      isLoading(true);
      errorMessage('');

      final folders =
          await _repository.listFolders(workRoomId, path: currentPath.value);
      currentFolders.assignAll(folders);

      print(
          "[FoldersController] refreshFolders: Found ${folders.length} folders");
    } catch (e) {
      print("[FoldersController] refreshFolders: Error occurred: $e");
      errorMessage('폴더 목록을 불러오는 중 오류가 발생했습니다.');
    } finally {
      isLoading(false);
    }
  }

  /// 현재 경로의 폴더 목록 조회
  Future<List<Folder>> listFolders(String workRoomId) async {
    try {
      print("[FoldersController] listFolders: Starting to list folders");
      print(
          "[FoldersController] listFolders: workRoomId=$workRoomId, currentPath=${currentPath.value}");

      isLoading(true);
      errorMessage('');

      final folders =
          await _repository.listFolders(workRoomId, path: currentPath.value);
      currentFolders.assignAll(folders); // 현재 폴더 목록 업데이트

      print(
          "[FoldersController] listFolders: Retrieved ${folders.length} folders");
      print(
          "[FoldersController] listFolders: Folders: ${folders.map((f) => f.folderName).join(', ')}");

      return folders;
    } catch (e) {
      print("[FoldersController] listFolders: Error occurred: $e");
      errorMessage('폴더 목록을 불러오는 중 오류가 발생했습니다.');
      return [];
    } finally {
      isLoading(false);
    }
  }

  /// 폴더 삭제
  Future<bool> deleteFolder(String folderId) async {
    try {
      print("[FoldersController] deleteFolder: Starting folder deletion");
      isLoading(true);
      errorMessage('');

      await _repository.deleteFolder(folderId);
      print("[FoldersController] deleteFolder: Folder deleted successfully");
      return true;
    } catch (e) {
      print("[FoldersController] deleteFolder: Error occurred: $e");
      errorMessage('폴더 삭제 중 오류가 발생했습니다.');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
