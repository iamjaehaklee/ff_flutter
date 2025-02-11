import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_overlay.dart';

class AnnotationOverlayWrapper extends StatelessWidget {
  final Rect selectionArea;
  final Function(Rect) onUpdate;
  final VoidCallback onIconTap;
  final bool isEditable;


  const AnnotationOverlayWrapper({
    Key? key,
    required this.selectionArea,
    required this.onUpdate,
    required this.onIconTap,
    required this.isEditable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotationOverlay(
      selectedRect: selectionArea,
      isEditable: isEditable,
      onUpdate: onUpdate,
      onIconTap: onIconTap,
    );
  }
}
