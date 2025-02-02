import 'package:get/get.dart';
import 'dart:io';

import 'package:legalfactfinder2025/features/files/data/file_repository.dart';

class FileViewController extends GetxController {
  final FileRepository fileRepository;

  FileViewController(this.fileRepository);

  Rx<File?> file = Rx<File?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> loadFile(String bucketName, String filePath, String fileName) async {
    try {
      isLoading.value = true;
      final downloadedFile = await fileRepository.downloadFile(
        bucketName: bucketName,
        filePath: filePath,
        fileName: fileName,
      );

      if (downloadedFile == null) {
        errorMessage.value = "Failed to load file.";
      } else {
        file.value = downloadedFile;
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
