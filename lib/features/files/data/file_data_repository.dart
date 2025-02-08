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
