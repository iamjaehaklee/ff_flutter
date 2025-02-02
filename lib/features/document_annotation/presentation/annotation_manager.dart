import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';

Rect createDefaultAnnotationRect(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  return Rect.fromCenter(
    center: Offset(screenWidth / 2, screenHeight / 2),
    width: 200,
    height: 150,
  );
}

Future<void> saveAnnotationToController(
    AnnotationController annotationController,
    String workRoomId,
    String fileName,
    int page,
    Rect? rect,
    String text,
    VoidCallback onSuccess,
    ) async {
  if (rect != null) {
    bool success = await annotationController.saveAnnotation(
      workRoomId: workRoomId,
      fileName: fileName,
      page: page,
      rect: rect,
      text: text,
      imageBytes: null,
    );

    if (success) {
      onSuccess();
    }
  }
}
