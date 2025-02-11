import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/annotation_repository.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';

class AnnotationController extends GetxController {
  final AnnotationRepository _annotationRepository = AnnotationRepository();

  RxList<Map<String, dynamic>> annotations = RxList<Map<String, dynamic>>([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;


  /// Getter: 현재 annotations 리스트의 첫 번째 항목을 DocumentAnnotationModel로 변환하여 반환
  DocumentAnnotationModel? get currentAnnotation {
    if (annotations.isNotEmpty) {
      try {
        return DocumentAnnotationModel.fromJson(annotations.first);
      } catch (e) {
        print("Error parsing annotation: $e");
        return null;
      }
    }
    return null;
  }

  Future<void> fetchAnnotations(String parentFileStorageKey) async {
    try {
      isLoading.value = true;
      final fetchedAnnotations =
      await _annotationRepository.fetchAnnotations(parentFileStorageKey);
      annotations.value = fetchedAnnotations;
    } catch (e) {
      errorMessage.value = "Failed to fetch annotations: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAnnotation({
    required String workRoomId,
    required String fileName,
    required int page,
    required Rect rect,
    required String text,
    Uint8List? imageBytes,
  }) async {
    try {
      bool success = await _annotationRepository.saveAnnotation(
        workRoomId: workRoomId,
        fileName: fileName,
        page: page,
        rect: rect,
        text: text,
        imageBytes: imageBytes,
      );

      if (success) {
        fetchAnnotations("$workRoomId/$fileName"); // ✅ 저장 후 최신 데이터 불러오기
      }
      return success;
    } catch (e) {
      errorMessage.value = "Failed to save annotation: $e";
      return false;
    }
  }
}
