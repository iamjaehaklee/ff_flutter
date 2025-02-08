import 'dart:io';

import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'file_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FileDataRepository {
  final supabase = Supabase.instance.client;



  // ✅ put_file_data 에지 함수 호출: files 테이블에 파일 정보 삽입
  Future<void> putFileData({
    required String fileName,
    required String storageKey,
    required String description,
    required String workRoomId,
    required String uploaderId,
  }) async {
    final url = Uri.parse('$baseUrl/functions/v1/put_file_data');

    /*
      uploader_id,         // 파일 업로드 시 클라이언트가 전달하는 uploader_id (파일 업로드시, 메시지 첨부용 파일이 아니면 반드시 전달)
      storage_key,         // 예: "work_room_id/타임스탬프가_붙은_파일명"
      file_name,           // 원본 파일명 (클라이언트가 전달)
      file_type,           // MIME 타입 (예: "image/jpeg", "application/pdf" 등)
      work_room_id,        // 파일이 속한 작업방 id
      description,         // 파일 설명 (옵션)
      chat_message_id      // 챗 메시지 첨부용 파일인 경우, 이미 생성된 챗 메시지 id (옵션)
    * */
     final fileType = fileName.split('.').last.toLowerCase();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'uploader_id': uploaderId,
        'storage_key':storageKey,
        'file_name': fileName,
        'file_type':fileType,
         'work_room_id': workRoomId,
        'description': description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to insert file data: ${response.body}");
    }
  }

  Future<List<FileData>> fetchFiles(String workRoomId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_files_by_work_room_id');

    try {
      Logger.i("Fetching files for WorkRoom ID: $workRoomId from $url");

      // Call the Edge Function
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'work_room_id': workRoomId}),
      );

      Logger.s("Status Code: ${response.statusCode}");
      Logger.s("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        Logger.s("Parsed JSON: $responseData");

        // Ensure the response contains the 'files' key
        if (responseData is! Map<String, dynamic> ||
            !responseData.containsKey('files')) {
          throw Exception("Unexpected response format: Missing 'files' key.");
        }

        final filesList = responseData['files'] as List<dynamic>;

        // Map the files list to FileData objects
        return filesList.map((json) {
          Logger.d("Processing JSON object: $json");
          return FileData(
            id: json['id'] as String? ?? '',
            storageKey: json['file_url'] as String? ?? '',
            fileName: json['file_name'] as String? ?? 'Unknown File',
            fileType: json['file_type'] as String? ?? 'unknown',
            fileSize: json['file_size'] as int? ?? 0,
            uploadedAt:
                DateTime.tryParse(json['uploaded_at'] as String? ?? '') ??
                    DateTime.now(),
            updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                DateTime.now(),
            workRoomId: workRoomId,
            uploaderId: json['uploader_id'] as String? ?? '',
            description: json['description'] as String? ?? 'No description',
            isDeleted: json['is_deleted'] as bool? ?? false,
            deletedAt: json['deleted_at'] != null
                ? DateTime.tryParse(json['deleted_at'] as String)
                : null,
          );
        }).toList();
      } else {
        throw Exception("Failed to fetch files: ${response.body}");
      }
    } catch (e) {
      Logger.e("Error fetching files", "FileFetch", e);
      throw Exception("Error fetching files: $e");
    }
  }



  // Download file from Supabase Storage
  Future<void> downloadFile(String fileName, String savePath) async {
    try {
      Logger.i('Downloading file: $fileName');
      
      final response =
          await supabase.storage.from('work_room_files').download(fileName);
      if (response.isEmpty) {
        throw Exception('Failed to download file.');
      }

      final file = File(savePath);
      await file.writeAsBytes(response);
      Logger.s('File downloaded successfully');
    } catch (e) {
      Logger.e('Error downloading file', 'FileDownload', e);
      throw Exception('Error downloading file: $e');
    }
  }
}
