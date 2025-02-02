import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'document_annotation_model.dart';
import 'package:legalfactfinder2025/constants.dart'; // ✅ constants.dart에서 가져옴
import 'package:http/http.dart' as http;

class AnnotationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 공통 로깅 함수
  void log(String level, String message) {
    const String reset = '\x1B[0m';
    const String infoColor = '\x1B[32m'; // 🟢 Green
    const String errorColor = '\x1B[31m'; // 🔴 Red
    const String warningColor = '\x1B[33m'; // 🟡 Yellow
    const String debugColor = '\x1B[34m'; // 🔵 Blue

    String prefix = switch (level) {
      'INFO' => '$infoColor🟢 [INFO]$reset',
      'ERROR' => '$errorColor🔴 [ERROR]$reset',
      'WARNING' => '$warningColor🟡 [WARNING]$reset',
      'DEBUG' => '$debugColor🔵 [DEBUG]$reset',
      _ => '[LOG]'
    };

    print('$prefix $message');
  }

  /// 📌 **주석 가져오기**
  Future<List<Map<String, dynamic>>> fetchAnnotations(String parentFileStorageKey) async {
    try {
      log('INFO', "Fetching annotations for parentFileStorageKey: $parentFileStorageKey...");

      final response = await _supabase.rpc(
        'get_document_annotations_by_parent_file_storage_key',
        params: { '_parent_file_storage_key': parentFileStorageKey },
      );

      if (response is List) {
        log('INFO', "✅ Successfully fetched annotations: ${response.length} records.");
        return List<Map<String, dynamic>>.from(response);
      } else {
        log('WARNING', "⚠️ Unexpected response format: ${response.runtimeType}");
        return [];
      }
    } catch (e, stackTrace) {
      log('ERROR', "❌ Error fetching annotations: $e");
      log('DEBUG', "🔍 Stack Trace: $stackTrace");
      rethrow;
    }
  }

  /// 📌 **주석 저장 (Database + Storage)**
  /// 📌 주석 저장 (Database + Storage)
  /// 📌 **주석 저장 (Edge Function 호출)**
  Future<bool> saveAnnotation({
    required String workRoomId,
    required String fileName,
    required int page,
    required Rect rect,
    required String text,
    Uint8List? imageBytes,
  }) async {
    try {
      log('INFO', "📝 Saving annotation via Edge Function...");

      final rectJson = DocumentAnnotationModel.rectToJson(rect);
      final String parentFileStorageKey = '$workRoomId/$fileName';

      log('INFO', "📂 Parent Storage Key: $parentFileStorageKey");

      String? imageFileStorageKey;
      if (imageBytes != null) {
        imageFileStorageKey =
        '$workRoomId/$fileName/page_${page}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now().toUtc())}.png';
      }

      // Edge Function에 전송할 데이터
      Map<String, dynamic> annotationData = {
        'document_id': null,
        'parent_file_storage_key': parentFileStorageKey,
        'work_room_id': workRoomId,
        'page_number': page,
        'x1': rectJson['x1'],
        'y1': rectJson['y1'],
        'x2': rectJson['x2'],
        'y2': rectJson['y2'],
        'content': text,
        'annotation_type': 'manual',
        'image_file_storage_key': imageFileStorageKey,
        'is_ocr': false,
        'ocr_text': null,
        'created_by': '01ba12d0-da6a-45e0-8535-6d2e49a4f96e',
      };

      log('INFO', "📤 Sending annotation data to Edge Function...");
      final response = await http.post(
        Uri.parse(putDocumentAnnotationEdgeFunctionUrl), // ✅ constants.dart의 URL 사용
        headers: {
          'Authorization': 'Bearer $jwtToken',
          "Content-Type": "application/json",
        },
        body: jsonEncode(annotationData),
      );



      if (response.statusCode == 200) {
        log('INFO', "✅ Annotation saved successfully via Edge Function.");
        return true;
      } else {
        log('ERROR', "❌ Failed to insert annotation via Edge Function: ${response.body}");
        return false;
      }
    } catch (e) {
      log('ERROR', "❌ Error saving annotation via Edge Function: $e");
      return false;
    }
  }

  /// 📌 **이미지 Public URL 가져오기**
  Future<String> getPublicUrl(String imageStorageKey) async {
    try {
      log('INFO', "🌍 Fetching public URL for: $imageStorageKey");

      final publicUrl = _supabase.storage
          .from('work_room_annotations')
          .getPublicUrl(imageStorageKey);

      log('INFO', "✅ Public URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      log('ERROR', "❌ Failed to get public URL for $imageStorageKey: $e");
      throw Exception("Failed to get public URL for $imageStorageKey.");
    }
  }
}
