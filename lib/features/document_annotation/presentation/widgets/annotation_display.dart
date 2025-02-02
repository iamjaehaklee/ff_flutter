import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_overlay.dart';

class AnnotationDisplay extends StatelessWidget {
  final List<DocumentAnnotationModel> annotations;
  final Rect? selectedRect;
  final bool isAnnotationMode;
  final VoidCallback toggleAnnotationMode;
  final Function(String) onSaveAnnotation;

  const AnnotationDisplay({
    Key? key,
    required this.annotations,
    required this.selectedRect,
    required this.isAnnotationMode,
    required this.toggleAnnotationMode,
    required this.onSaveAnnotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var annotation in annotations)
          AnnotationOverlay(
            annotation: annotation,
            selectedRect: Rect.fromLTRB(
              annotation.x1 ?? 0.0,
              annotation.y1 ?? 0.0,
              annotation.x2 ?? 0.0,
              annotation.y2 ?? 0.0,
            ),
            isEditable: false,
            onUpdate: (_) {},
            onIconTap: () {},
          ),
      ],
    );
  }
}
