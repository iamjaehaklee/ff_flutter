import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';
import 'package:legalfactfinder2025/features/files/data/file_data_repository.dart';
import 'package:legalfactfinder2025/features/files/data/file_repository.dart';

class FileListController extends GetxController {
  final FileDataRepository fileDataRepository = FileDataRepository();
  final FileRepository fileRepository = FileRepository();

  var files = <FileData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ✅ 파일 목록 가져오기
  Future<void> fetchFiles(String workRoomId) async {
    final startTime = DateTime.now();
    print("🔄 [FileListController] Fetching files for WorkRoom '$workRoomId' at $startTime");

    isLoading.value = true;
    errorMessage.value = '';

    try {
      files.value = await fileDataRepository.fetchFiles(workRoomId);
      print("✅ [FileListController] Successfully fetched ${files.length} files for WorkRoom '$workRoomId'");
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
  Future<void> uploadFile(String path, String fileName, String description, String workRoomId, String uploaderId) async {
    final startTime = DateTime.now();
    print("🔄 [FileListController] Uploading file '$fileName' to WorkRoom '$workRoomId' at $startTime");

    isLoading.value = true;

    try {
      await fileRepository.uploadFile(
        path: path,
        timeStampedFileName: fileName,
        description: description,
        workRoomId: workRoomId,
        uploaderId: uploaderId,
      );

      print("✅ [FileListController] File '$fileName' uploaded successfully!");
      await fetchFiles(workRoomId); // ✅ 업로드 후 리스트 갱신
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
}
