// lib/file_list_controller.dart
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';
import 'package:legalfactfinder2025/features/files/data/file_data_repository.dart';
import 'package:legalfactfinder2025/features/files/data/file_repository.dart';

class FileListController extends GetxController {
  final FileDataRepository fileDataRepository = FileDataRepository();
  final FileRepository  fileRepository = FileRepository();

  var fileDataList = <FileData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ✅ 파일 목록 가져오기 (WorkRoom 단위)
  Future<void> fetchFileDataList(String workRoomId) async {
    final startTime = DateTime.now();
    print("🔄 [FileListController] Fetching files for WorkRoom '$workRoomId' at $startTime");

    isLoading.value = true;
    errorMessage.value = '';

    try {
      fileDataList.value = await fileDataRepository.fetchFiles(workRoomId);
      print("✅ [FileListController] Successfully fetched ${fileDataList.length} files for WorkRoom '$workRoomId'");
    } catch (e, stacktrace) {
      errorMessage.value = 'Failed to load files: ${e.toString()}';
      print("❌ [FileListController] Error fetching files: $e");
      print("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading.value = false;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("⏳ [FileListController] fetchFiles completed in ${duration.inMilliseconds}ms");
    }
  }

  // ✅ 파일 업로드
  // ✅ 파일 업로드
  Future<void> uploadFileToStorageAndPutFileData(String path, String fileName, String description, String workRoomId, String uploaderId) async {
    final startTime = DateTime.now();
    print("🔄 [FileListController] Uploading file '$fileName' to WorkRoom '$workRoomId' at $startTime");

    isLoading.value = true;

    try {
      // 파일 이름에 타임스탬프를 붙이는 로직
      final timeStampedFileName = generateTimestampedFileName(fileName);

      // 1-1. 스토리지에 파일 업로드
      String storageKey=   await fileRepository.uploadFileToStorage(
        path: path,
        timeStampedFileName: timeStampedFileName,
        description: description,
        workRoomId: workRoomId,
        uploaderId: uploaderId,
      );


       // 1-2. Edge function 호출: put_file_data로 files 테이블에 파일 정보 입력
      await fileDataRepository.putFileData(
        fileName: timeStampedFileName,
        storageKey: storageKey,
         workRoomId: workRoomId,
        uploaderId: uploaderId,
        description: description,
       );


      print("✅ [FileListController] File '$fileName' uploaded and file data inserted successfully!");
      // 파일 업로드 및 데이터 삽입 후 파일 목록 갱신
      await fetchFileDataList(workRoomId);
    } catch (e, stacktrace) {
      errorMessage.value = 'Failed to upload file: ${e.toString()}';
      print("❌ [FileListController] Error uploading file: $e");
      print("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading.value = false;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("⏳ [FileListController] uploadFile completed in ${duration.inMilliseconds}ms");
    }
  }

  // ✅ 파일 다운로드
  Future<void> downloadFile(String fileName, String savePath) async {
    final startTime = DateTime.now();
    print("🔄 [FileListController] Downloading file '$fileName' to '$savePath' at $startTime");

    isLoading.value = true;

    try {
      await fileDataRepository.downloadFile(fileName, savePath);
      print("✅ [FileListController] File '$fileName' downloaded successfully to '$savePath'");
    } catch (e, stacktrace) {
      errorMessage.value = 'Failed to download file: ${e.toString()}';
      print("❌ [FileListController] Error downloading file: $e");
      print("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading.value = false;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("⏳ [FileListController] downloadFile completed in ${duration.inMilliseconds}ms");
    }
  }

  // ✅ 특정 폴더(파일 저장 경로)에 해당하는 파일 목록 가져오기
  // fileDataList가 미리 fetchFileDataList로 채워졌다고 가정합니다.
  Future<List<FileData>> listFiles(String folderPath) async {
    if (fileDataList.isEmpty) {
      // 필요한 경우 workRoomId를 인자로 받아 fetchFileDataList를 호출할 수도 있습니다.
      return [];
    }
    // storageKey가 파일 저장 경로이므로 이를 기준으로 필터링
    return fileDataList.where((fileData) => fileData.storageKey == folderPath).toList();
  }
}
