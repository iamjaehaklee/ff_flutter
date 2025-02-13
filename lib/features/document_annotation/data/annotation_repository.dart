import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/file_utils.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'document_annotation_model.dart';
import 'package:legalfactfinder2025/constants.dart'; // constants.dart에서 가져옴
import 'package:http/http.dart' as http;

class AnnotationRepository {
  static const String _tag = 'AnnotationRepository';
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

  ///
  Future<List<Map<String, dynamic>>> fetchAnnotations(
      String parentFileStorageKey) async {
    debugPrint(
        '$_tag [fetchAnnotations] : parentFileStorageKey=$parentFileStorageKey');
    try {
      debugPrint('$_tag [fetchAnnotations] Supabase ');
      final response = await _supabase.rpc(
        'get_document_annotations_by_parent_file_storage_key',
        params: {'_parent_file_storage_key': parentFileStorageKey},
      );

      if (response is List) {
        debugPrint('$_tag [fetchAnnotations] : ${response.length}');
        log('INFO',
            " Successfully fetched annotations: ${response.length} records.");
        return List<Map<String, dynamic>>.from(response);
      } else {
        log('WARNING', " Unexpected response format: ${response.runtimeType}");
        return [];
      }
    } catch (e, stackTrace) {
      log('ERROR', " Error fetching annotations: $e");
      log('DEBUG', " Stack Trace: $stackTrace");
      rethrow;
    }
  }

  /// ** (Database + Storage)**
  /// ** (Database + Storage)**
  /// ** (Edge Function )**
  Future<bool> saveAnnotation({
    required String workRoomId,
    required String fileName,
    required int page,
    required Rect rect,
    required String text,
    Uint8List? imageBytes,
  }) async {
    debugPrint('$_tag [saveAnnotation] ');
    debugPrint(
        '$_tag [saveAnnotation] : workRoomId=$workRoomId, fileName=$fileName, page=$page');
    AuthController authController = Get.find<AuthController>();
    String? userId = authController.getUserId();

    if (userId == null) {
      log('ERROR', " User ID is null. Cannot save annotation.");
      return false;
    }

    try {
      // 부모 파일 스토리지 키: work_room_id와 fileName(파일 테이블의 id)를 조합
      final String parentFileStorageKey = '$workRoomId/$fileName';
      debugPrint(
          '$_tag [saveAnnotation] parentFileStorageKey : $parentFileStorageKey');

      final rectJson = DocumentAnnotationModel.rectToJson(rect);

      String? imageFileStorageKey;
      if (imageBytes != null) {
        // 타임스탬프 생성 후 지정된 형식에 맞게 이미지 파일 스토리지 키 생성
        final timestamp =
            DateFormat('yyyyMMdd_HHmmss').format(DateTime.now().toUtc());
        imageFileStorageKey =
            '$workRoomId/${replaceFileExtensionSeparator(fileName)}/page_${page}__${timestamp}.png';

        // Supabase Storage에 이미지 업로드 (work_room_annotations 버킷)
        final supabase = Supabase.instance.client;
        try {
          // uploadBinary는 성공 시 String key를 반환함
          final uploadKey =
              await supabase.storage.from('work_room_annotations').uploadBinary(
                    imageFileStorageKey,
                    imageBytes,
                    fileOptions: const FileOptions(upsert: false),
                  );
          debugPrint(
              '$_tag [saveAnnotation] Image uploaded successfully: $uploadKey');
        } catch (uploadError) {
          log('ERROR', "Image upload failed: $uploadError");
          return false;
        }
      }

      // 업로드된 이미지 경로를 포함하여 annotation 데이터를 구성
      Map<String, dynamic> annotationData = {
        'document_id': null,
        'parent_file_storage_key': parentFileStorageKey,
        'work_room_id': workRoomId,
        'page_number': page,
        'area_left': rect.left,
        'area_top': rect.top,
        'area_width': rect.width,
        'area_height': rect.height,
        'content': text,
        'annotation_type': 'manual',
        'image_file_storage_key': imageFileStorageKey,
        'is_ocr': false,
        'ocr_text': null,
        'created_by': userId,
      };

      debugPrint(
          '$_tag [saveAnnotation] Edge Function call with data: ${jsonEncode(annotationData)}');

      // Edge Function을 통해 annotationData를 DB에 업로드
      final response = await http.post(
        Uri.parse(putDocumentAnnotationEdgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          "Content-Type": "application/json",
        },
        body: jsonEncode(annotationData),
      );

      if (response.statusCode == 200) {
        debugPrint(
            '$_tag [saveAnnotation] Annotation saved successfully via Edge Function');
        log('INFO', " Annotation saved successfully via Edge Function.");
        // 업로드 및 DB 저장 성공 후, UI 갱신: AnnotationController를 통해 최신 annotation 목록 다시 불러오기
        Get.find<AnnotationController>()
            .fetchAnnotationsByParentFileStorageKey(parentFileStorageKey);
        return true;
      } else {
        log('ERROR',
            " Failed to insert annotation via Edge Function: ${response.body}");
        return false;
      }
    } catch (e) {
      log('ERROR', " Error saving annotation via Edge Function: $e");
      return false;
    }
  }

  Future<bool> deleteAnnotation(String annotationId) async {
    debugPrint('$_tag [deleteAnnotation] 시작: annotationId=$annotationId');

    try {
      // 먼저 이미지가 있다면 삭제
      final response = await _supabase
          .from('document_annotations')
          .select('image_file_storage_key')
          .eq('id', annotationId)
          .single();

      final String? imageKey = response['image_file_storage_key'];
      if (imageKey != null) {
        debugPrint('$_tag [deleteAnnotation] 이미지 삭제 시도: $imageKey');
        await _supabase.storage
            .from('work_room_annotations')
            .remove([imageKey]);
        debugPrint('$_tag [deleteAnnotation] 이미지 삭제 완료');
      }

      // 어노테이션 삭제
      debugPrint('$_tag [deleteAnnotation] 어노테이션 데이터 삭제');
      await _supabase.from('document_annotations').delete().eq('id', annotationId);
      debugPrint('$_tag [deleteAnnotation] 삭제 완료');

      return true;
    } catch (e) {
      debugPrint('$_tag [deleteAnnotation] 오류 발생: $e');
      return false;
    }
  }
}
