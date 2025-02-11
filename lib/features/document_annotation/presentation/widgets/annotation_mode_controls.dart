// File: lib/widgets/annotation_mode_controls.dart
import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_overlay_wrapper.dart';

typedef RectCallback = void Function(Rect newRect);
typedef VoidCallback = void Function();

class AnnotationModeControls extends StatelessWidget {
  final Rect selectionArea;
  final RectCallback onUpdate;
  final VoidCallback onIconTap;
  final VoidCallback onWriteComment;

  const AnnotationModeControls({
    Key? key,
    required this.selectionArea,
    required this.onUpdate,
    required this.onIconTap,
    required this.onWriteComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(
            child: AnnotationOverlayWrapper(
              selectionArea: selectionArea,
              isEditable: true,
              onUpdate: onUpdate,
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
                    onPressed: onWriteComment,
                    child: const Text("Write comment"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// End of AnnotationModeControls class
}
