import 'package:flutter/material.dart';

class CornerMarkerWidget extends StatelessWidget {
  final Offset position;
  final Alignment alignment;
  final Function(Offset delta) onDrag;

  const CornerMarkerWidget({
    Key? key,
    required this.position,
    required this.alignment,
    required this.onDrag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
