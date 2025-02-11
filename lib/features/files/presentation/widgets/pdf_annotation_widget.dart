import 'package:flutter/material.dart';

class PDFAnnotationWidget extends StatelessWidget {
  final Rect selectionArea;
  final Function(Rect) onSelectionChanged;
  final VoidCallback onCapture;

  const PDFAnnotationWidget({
    Key? key,
    required this.selectionArea,
    required this.onSelectionChanged,
    required this.onCapture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: selectionArea,
          child: GestureDetector(
            onPanUpdate: (details) {
              final newRect = Rect.fromLTWH(
                selectionArea.left + details.delta.dx,
                selectionArea.top + details.delta.dy,
                selectionArea.width,
                selectionArea.height,
              );
              onSelectionChanged(newRect);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: onCapture,
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }
}
