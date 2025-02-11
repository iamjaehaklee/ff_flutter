// File: lib/utils/selection_area_utils.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

// normalizeRect: 항상 양수의 width와 height를 갖도록
Rect normalizeRect(Rect rect) {
  return Rect.fromLTRB(
    math.min(rect.left, rect.right),
    math.min(rect.top, rect.bottom),
    math.max(rect.left, rect.right),
    math.max(rect.top, rect.bottom),
  );
}

// 🟡 clampSelectionArea(): BoxFit.contain 적용 시, container 내 실제 이미지 영역(레터박스)을 계산하여 선택 영역을 제한
Rect clampSelectionArea(Rect selection, Size containerSize, Size capturedImageSize) {
  final double imageAspect = capturedImageSize.width / capturedImageSize.height;
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
  final double left = selection.left < offsetX ? offsetX : selection.left;
  final double top = selection.top < offsetY ? offsetY : selection.top;
  final double right = selection.right > offsetX + displayedWidth ? offsetX + displayedWidth : selection.right;
  final double bottom = selection.bottom > offsetY + displayedHeight ? offsetY + displayedHeight : selection.bottom;
  return Rect.fromLTRB(left, top, right, bottom);
} // End of clampSelectionArea() 🟡
