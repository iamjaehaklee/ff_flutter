import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/files/data/file_model.dart';
import 'package:legalfactfinder2025/features/files/file_list_controller.dart';

class FileInfoScreen extends StatefulWidget {
  final String storageKey;

  const FileInfoScreen({
    Key? key,
    required this.storageKey,
  }) : super(key: key);

  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends State<FileInfoScreen> {
  final FileListController fileListController = Get.find<FileListController>();
  FileData? fileData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFileInfo();
  }

  Future<void> _loadFileInfo() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // storageKey를 기반으로 파일 정보 가져오기
      await fileListController.fetchFileDataListByStoragePath(widget.storageKey);

      // 가져온 목록에서 해당 파일 찾기
      fileData = fileListController.fileDataList.firstWhere(
            (file) => file.storageKey == widget.storageKey,
        orElse: () => throw Exception("File not found"),
      );

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        errorMessage = '파일 정보를 불러오는 데 실패했습니다.\n오류: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("파일 정보"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📂 파일명: ${fileData!.fileName}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("📝 설명: ${fileData!.description ?? '설명 없음'}"),
            const SizedBox(height: 8),
            Text("📁 파일 유형: ${fileData!.fileType ?? '알 수 없음'}"),
            const SizedBox(height: 8),
            Text("📏 파일 크기: ${fileData!.fileSize} bytes"),
            const SizedBox(height: 8),
            Text("📅 업로드 날짜: ${fileData!.uploadedAt.toLocal()}"),
            const SizedBox(height: 8),
            Text("👤 업로더 ID: ${fileData!.uploaderId}"),
          ],
        ),
      ),
    );
  }
}
