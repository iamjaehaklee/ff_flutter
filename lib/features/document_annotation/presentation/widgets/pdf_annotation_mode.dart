import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/input_annotation_bottom_sheet.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_overlay_wrapper.dart';
import 'dart:typed_data';

class PdfAnnotationMode extends StatelessWidget {
  final Uint8List capturedImage;
  final GlobalKey annotationBoundaryKey;
  final Rect selectionArea;
  final ValueChanged<Rect> onSelectionChanged;
  final VoidCallback onIconTap;
  final VoidCallback onCaptureSelectedArea;

  const PdfAnnotationMode({
    Key? key,
    required this.capturedImage,
    required this.annotationBoundaryKey,
    required this.selectionArea,
    required this.onSelectionChanged,
    required this.onIconTap,
    required this.onCaptureSelectedArea,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 캡쳐된 페이지 이미지 표시
        Positioned.fill(
          child: RepaintBoundary(
            key: annotationBoundaryKey,
            child: Image.memory(
              capturedImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // 어노테이션 오버레이 및 하단 버튼
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: AnnotationOverlayWrapper(
                  selectionArea: selectionArea,
                  isEditable: true,
                  onUpdate: onSelectionChanged,
                  onIconTap: onIconTap,
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 140,
                      child: TextButton(
                        onPressed: onIconTap,
                        child: const Text("Cancel"),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: onCaptureSelectedArea,
                        child: const Text("Write comment"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} // End of PdfAnnotationMode
