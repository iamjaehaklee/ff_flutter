// File: lib/utils/pdf_file_view_state_helpers.dart
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/core/utils/selection_area_utils.dart';

/// initializeSelectionArea: 화면 중앙에 80% 너비, 40% 높이의 선택 영역(Rect)을 생성하여 반환합니다.
Rect initializeSelectionArea(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final center = Offset(size.width / 2, size.height / 2);
  final width = size.width * 0.8;
  final height = size.height * 0.4;
  return Rect.fromCenter(center: center, width: width, height: height);
} // End of initializeSelectionArea()

/// captureSelectedArea: 캡쳐된 이미지의 letterboxed 영역을 고려하여 선택 영역을 크롭한 후, PNG 데이터(Uint8List)를 반환합니다.
Future<Uint8List?> captureSelectedArea({
  required Rect selectionArea,
  required Uint8List capturedImage,
  required ui.Size capturedImageSize,
  required Size containerSize,
}) async {
  try {
    final normalizedSelection = normalizeRect(selectionArea);

    // 실제 이미지가 표시되는 영역 계산 (BoxFit.contain)
    final double imageAspect =
        capturedImageSize.width / capturedImageSize.height;
    final double containerAspect = containerSize.width / containerSize.height;
    double displayedWidth, displayedHeight, offsetX, offsetY;
    if (containerAspect > imageAspect) {
      displayedHeight = containerSize.height;
      displayedWidth = displayedHeight * imageAspect;
      offsetX = (containerSize.width - displayedWidth) / 2;
      offsetY = 0;
    } else {
      displayedWidth = containerSize.width;
      displayedHeight = displayedWidth / imageAspect;
      offsetX = 0;
      offsetY = (containerSize.height - displayedHeight) / 2;
    }

    // clamp selection
    final Rect clampedSelection = clampSelectionArea(
        normalizedSelection, containerSize, capturedImageSize);

    // letterbox offset 제거 (실제 이미지 내 좌표)
    final Rect adjustedSelection = Rect.fromLTWH(
      clampedSelection.left - offsetX,
      clampedSelection.top - offsetY,
      clampedSelection.width,
      clampedSelection.height,
    );

    // 스케일: 실제 이미지 크기 / 표시된 이미지 크기
    final double scaleX = capturedImageSize.width / displayedWidth;
    final double scaleY = capturedImageSize.height / displayedHeight;

    final Rect imageSelection = Rect.fromLTWH(
      adjustedSelection.left * scaleX,
      adjustedSelection.top * scaleY,
      adjustedSelection.width * scaleX,
      adjustedSelection.height * scaleY,
    );

    if (imageSelection.width <= 0 || imageSelection.height <= 0) {
      debugPrint(
          "Error: Invalid image dimensions (width: ${imageSelection.width}, height: ${imageSelection.height})");
      return null;
    }

    final ui.Image fullImage = await decodeImageFromList(capturedImage);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      fullImage,
      imageSelection,
      Rect.fromLTWH(0, 0, imageSelection.width, imageSelection.height),
      Paint(),
    );
    final ui.Image croppedImage = await recorder
        .endRecording()
        .toImage(imageSelection.width.toInt(), imageSelection.height.toInt());
    final ByteData? croppedByteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    if (croppedByteData != null) {
      return croppedByteData.buffer.asUint8List();
    } else {
      return null;
    }
  } catch (e) {
    debugPrint("Error capturing selected area in helper: $e");
    return null;
  }
} // End of captureSelectedArea()
