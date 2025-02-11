// File: lib/widgets/annotation_mode_overlay.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AnnotationModeOverlay extends StatelessWidget {
  final Uint8List? capturedImage;

  const AnnotationModeOverlay({
    Key? key,
    required this.capturedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (capturedImage == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Image.memory(
          capturedImage!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
// End of AnnotationModeOverlay class
}
