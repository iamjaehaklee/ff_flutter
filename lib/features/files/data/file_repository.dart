import 'dart:io';
import 'dart:typed_data';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;

class FileRepository {
  final supabase = Supabase.instance.client;

  /// Supabase Storage에서 파일을 다운로드하여 로컬에 저장하고, 저장된 File 객체를 반환합니다.
  Future<File?> downloadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
  }) async {
    try {
      print(
          "[FileRepository] downloadFile: Starting download for file at $bucketName/$filePath");

      // Supabase Storage에서 파일 다운로드
      final Uint8List response =
          await supabase.storage.from(bucketName).download(filePath);
      print(
          "[FileRepository] downloadFile: File downloaded from Supabase. Response size: ${response.lengthInBytes} bytes");

      // 로컬 저장 경로 설정
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$fileName';
      print(
          "[FileRepository] downloadFile: Local directory path: ${directory.path}");

      final file = File(localPath);
      await file.writeAsBytes(response);
      print("[FileRepository] downloadFile: File saved locally at: $localPath");

      return file;
    } catch (e) {
      print(
          "[FileRepository] downloadFile: Error occurred while downloading file: $e");
      return null;
    }
  }

  /// Supabase Storage에 파일을 업로드합니다.
  /// [path]는 업로드할 경로, [timeStampedFileName]은 업로드 시 사용할 파일명, [description]은 설명, [workRoomId]와 [uploaderId]는 메타데이터입니다.
  Future<String> uploadFile({
    required String path,
    required String timeStampedFileName,
    required String description,
    required String workRoomId,
    required String uploaderId,
    bool? isThumbnail,
  }) async {
    try {
      print("[FileRepository] uploadFile: Starting file upload for $timeStampedFileName");
      final file = File(path);
      print("[FileRepository] uploadFile: File exists at path: $path");

      String storageKey;
      if (isThumbnail == null || isThumbnail == false) {
        // 일반 파일 업로드: 타임스탬프가 붙은 파일명 사용
        print("[FileRepository] uploadFile: Using timestamped file name: $timeStampedFileName");
        storageKey = '$workRoomId/$timeStampedFileName';
        final storageResponse = await supabase.storage
            .from('work_room_files')
            .upload(storageKey, file);
        if (storageResponse.isEmpty) {
          print("[FileRepository] uploadFile: Storage response is empty. Upload failed.");
          throw Exception('Failed to upload file.');
        }
        print("[FileRepository] uploadFile: File uploaded successfully to $storageKey");
        Logger.s('File uploaded successfully');
      } else {
        // 썸네일 업로드: 타임스탬프 없이 업로드 (파일명에 "thumb_" 접두사가 이미 붙어 있다고 가정)
        print("[FileRepository] uploadFile: Uploading thumbnail file: $timeStampedFileName");
        storageKey = '$workRoomId/$timeStampedFileName';
        final storageResponse = await supabase.storage
            .from('work_room_thumbnails')
            .upload(storageKey, file);
        if (storageResponse.isEmpty) {
          print("[FileRepository] uploadFile: Storage response is empty. Upload failed.");
          throw Exception('Failed to upload file.');
        }
        print("[FileRepository] uploadFile: File uploaded successfully to $storageKey");
        Logger.s('File uploaded successfully');
      }
      return storageKey;
    } catch (e) {
      print("[FileRepository] uploadFile: Error uploading file: $e");
      Logger.e('Error uploading file', 'FileUpload', e);
      throw Exception('Error uploading file: $e');
    }
  }


  /// 이미지 파일의 썸네일을 생성하는 헬퍼 함수
  /// [imageFile]을 받아 너비 200픽셀로 리사이즈한 후, 임시 디렉토리에 저장하고 File 객체를 반환합니다.
  Future<File> generateThumbnail(File imageFile) async {
    try {
      print(
          "[FileRepository] generateThumbnail: Starting thumbnail generation for file: ${imageFile.path}");

      // 파일의 바이트 읽기
      final bytes = await imageFile.readAsBytes();
      print(
          "[FileRepository] generateThumbnail: Read ${bytes.length} bytes from image file");

      // 이미지 디코딩
      final img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        print("[FileRepository] generateThumbnail: Decoding image failed");
        throw Exception("Failed to decode image for thumbnail generation");
      }
      print(
          "[FileRepository] generateThumbnail: Image decoded successfully. Dimensions: ${decodedImage.width}x${decodedImage.height}");

      // 썸네일 생성 (너비 200픽셀로 리사이즈)
      final img.Image thumbnail = img.copyResize(decodedImage, width: 200);
      print(
          "[FileRepository] generateThumbnail: Thumbnail generated. New dimensions: ${thumbnail.width}x${thumbnail.height}");

      // 임시 디렉토리 경로 획득
      final tempDir = await getTemporaryDirectory();
      print(
          "[FileRepository] generateThumbnail: Temporary directory obtained: ${tempDir.path}");
      final thumbnailFileName = 'thumb_${imageFile.path.split('/').last}';
      final thumbnailPath = '${tempDir.path}/$thumbnailFileName';
      print(
          "[FileRepository] generateThumbnail: Thumbnail will be saved at: $thumbnailPath");

      final thumbnailFile = File(thumbnailPath);

      // JPEG 형식으로 인코딩하여 저장
      final thumbnailBytes = img.encodeJpg(thumbnail);
      await thumbnailFile.writeAsBytes(thumbnailBytes);
      print(
          "[FileRepository] generateThumbnail: Thumbnail saved successfully at: $thumbnailPath");

      return thumbnailFile;
    } catch (e) {
      print(
          "[FileRepository] generateThumbnail: Error generating thumbnail: $e");
      throw Exception("Thumbnail generation failed: $e");
    }
  }
}
