import 'package:flutter/material.dart';

class AnnotationOverlayPainter extends CustomPainter {
  final Rect transparentRect;

  AnnotationOverlayPainter({required this.transparentRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54 // 반투명 검정색 오버레이
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 선택된 영역을 잘라내서 투명하게 유지
    path.addRect(transparentRect);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
