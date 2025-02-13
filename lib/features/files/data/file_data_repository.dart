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
    required String storagePath,
    required String description,
    required String workRoomId,
    required String uploaderId,
  }) async {
    final url = Uri.parse('$baseUrl/functions/v1/put_file_data');

    /*
      uploader_id,         // 파일 업로드 시 클라이언트가 전달하는 uploader_id (파일 업로드시, 메시지 첨부용 파일이 아니면 반드시 전달)
      storage_key,         // 예: "work_room_id/타임스탬프가_붙은_파일명"
      storage_path,        // "work_room_id"까지. 즉,마지막 역슬레시는 없음
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
        'storage_path':storagePath,
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

  Future<List<FileData>> fetchFilesByStoragePath(String storagePath) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_files_by_storage_path');

    try {
      Logger.i("Fetching files for storagePath: $storagePath from $url");

      // Call the Edge Function with the storage_path parameter
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'storage_path': storagePath}),
      );

      Logger.s("Status Code: ${response.statusCode}");
      Logger.s("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        Logger.s("Parsed JSON: $responseData");

        // Support both a plain list and a map with a "data" key
        List<dynamic> filesList;
        if (responseData is List) {
          filesList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          filesList = responseData['data'] as List<dynamic>;
        } else {
          throw Exception("Unexpected response format: Missing 'data' key.");
        }

        // Map the files list to FileData objects using the FileData.fromJson constructor
        return filesList.map((json) {
          Logger.d("Processing JSON object: $json");
          return FileData.fromJson(json as Map<String, dynamic>);
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
