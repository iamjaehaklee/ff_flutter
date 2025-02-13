import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/annotation_repository.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';

class AnnotationController extends GetxController {
  static const String _tag = 'AnnotationController';
  final AnnotationRepository _annotationRepository = AnnotationRepository();

  RxList<DocumentAnnotationModel> annotations =
      RxList<DocumentAnnotationModel>([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  DocumentAnnotationModel? get currentAnnotation {
    debugPrint('$_tag [currentAnnotation] 현재 어노테이션 접근 시도');
    if (annotations.isNotEmpty) {
      try {
        debugPrint('$_tag [currentAnnotation] 첫 번째 어노테이션 파싱 시도');
        final annotation = annotations.first;
        debugPrint('$_tag [currentAnnotation] 파싱 성공: ${annotation.id}');
        return annotation;
      } catch (e) {
        debugPrint('$_tag [currentAnnotation] 파싱 오류 발생: $e');
        return null;
      }
    }
    debugPrint('$_tag [currentAnnotation] 사용 가능한 어노테이션 없음');
    return null;
  }

  Future<void> fetchAnnotationsByParentFileStorageKey(
      String parentFileStorageKey) async {
    debugPrint('$_tag [fetchAnnotations] 시작: $parentFileStorageKey');
    try {
      debugPrint('$_tag [fetchAnnotations] 로딩 상태 설정');
      isLoading.value = true;

      debugPrint('$_tag [fetchAnnotations] 저장소에서 어노테이션 조회 시작');
      final fetchedAnnotations =
          await _annotationRepository.fetchAnnotations(parentFileStorageKey);
      debugPrint(
          '$_tag [fetchAnnotations] 조회 성공: ${fetchedAnnotations.length}개의 어노테이션');

      annotations.value = fetchedAnnotations
          .map((json) => DocumentAnnotationModel.fromJson(json))
          .toList();
      debugPrint('$_tag [fetchAnnotations] 어노테이션 목록 업데이트 완료');
    } catch (e) {
      debugPrint('$_tag [fetchAnnotations] 오류 발생: $e');
      errorMessage.value = "Failed to fetch annotations: $e";
    } finally {
      debugPrint('$_tag [fetchAnnotations] 로딩 상태 해제');
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
    debugPrint('$_tag [saveAnnotation] 시작');
    debugPrint(
        '$_tag [saveAnnotation] 파라미터: workRoomId=$workRoomId, fileName=$fileName, page=$page');

    try {
      debugPrint('$_tag [saveAnnotation] 저장소에 어노테이션 저장 시도');
      bool success = await _annotationRepository.saveAnnotation(
        workRoomId: workRoomId,
        fileName: fileName,
        page: page,
        rect: rect,
        text: text,
        imageBytes: imageBytes,
      );

      if (success) {
        debugPrint('$_tag [saveAnnotation] 저장 성공');
        debugPrint('$_tag [saveAnnotation] 어노테이션 목록 새로고침 시작');
        await fetchAnnotationsByParentFileStorageKey("$workRoomId/$fileName");
        debugPrint('$_tag [saveAnnotation] 어노테이션 목록 새로고침 완료');
      } else {
        debugPrint('$_tag [saveAnnotation] 저장 실패');
      }
      return success;
    } catch (e) {
      debugPrint('$_tag [saveAnnotation] 오류 발생: $e');
      errorMessage.value = "Failed to save annotation: $e";
      return false;
    }
  }

  Future<bool> deleteAnnotation(String annotationId) async {
    debugPrint('$_tag [deleteAnnotation] 시작');
    debugPrint('$_tag [deleteAnnotation] annotationId=$annotationId');

    try {
      // 삭제 전에 parentFileStorageKey 저장
      final annotation = annotations.firstWhere((a) => a.id == annotationId);
      final parentKey = annotation.parentFileStorageKey;

      final success =
          await _annotationRepository.deleteAnnotation(annotationId);

      if (success) {
        debugPrint('$_tag [deleteAnnotation] 삭제 성공');
        // 목록 새로고침
        if (parentKey != null) {
          await fetchAnnotationsByParentFileStorageKey(parentKey);
        }
      } else {
        debugPrint('$_tag [deleteAnnotation] 삭제 실패');
      }

      return success;
    } catch (e) {
      debugPrint('$_tag [deleteAnnotation] 오류 발생: $e');
      errorMessage.value = "Failed to delete annotation: $e";
      return false;
    }
  }

  List<DocumentAnnotationModel> getAnnotationsForPage(int page) {
    return annotations
        .where((annotation) => annotation.pageNumber == page)
        .toList();
  }
}
