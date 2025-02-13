import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:legalfactfinder2025/features/files/data/file_repository.dart';

class FileViewController extends GetxController {
  final FileRepository fileRepository;

  FileViewController(this.fileRepository);

  Rx<File?> file = Rx<File?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> loadFile(
      String bucketName, String filePath, String fileName) async {
    debugPrint(
        "FileViewController: 파일 로딩 시작 [$bucketName/$filePath/$fileName]");

    try {
      isLoading.value = true;
      errorMessage.value = "";
      file.value = null;

      debugPrint("FileViewController: 파일 다운로드 요청...");
      final downloadedFile = await fileRepository.downloadFile(
        bucketName: bucketName,
        filePath: filePath,
        fileName: fileName,
      );

      if (downloadedFile == null) {
        errorMessage.value = "Failed to load file.";
        debugPrint(
            "FileViewController: 파일 다운로드 실패 [$bucketName/$filePath/$fileName]");
      } else {
        file.value = downloadedFile;
        debugPrint(
            "FileViewController: 파일 다운로드 성공 - 경로: ${downloadedFile.path}");
      }
    } catch (e, stackTrace) {
      errorMessage.value = "An error occurred: $e";
      debugPrint("FileViewController: 오류 발생 - $e");
      debugPrint("FileViewController: 스택 트레이스 - $stackTrace");
    } finally {
      isLoading.value = false;
      debugPrint("FileViewController: 파일 로딩 완료");
    }
  }
}
