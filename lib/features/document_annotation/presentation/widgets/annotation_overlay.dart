import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';

class AnnotationOverlay extends StatefulWidget {
  final DocumentAnnotationModel annotation;
  final Rect selectedRect;
  final Function(Rect) onUpdate;
  final VoidCallback onIconTap;
  final bool isEditable;

  const AnnotationOverlay({
    Key? key,
    required this.annotation,
    required this.selectedRect,
    required this.onUpdate,
    required this.onIconTap,
    this.isEditable = false,
  }) : super(key: key);

  @override
  _AnnotationOverlayState createState() => _AnnotationOverlayState();
}

class _AnnotationOverlayState extends State<AnnotationOverlay> {
  late Rect _rect;

  @override
  void initState() {
    super.initState();
    _rect = widget.selectedRect;
  }

  void _updateCorner(Offset delta, Alignment alignment) {
    if (!widget.isEditable) return;

    setState(() {
      double left = _rect.left;
      double top = _rect.top;
      double right = _rect.right;
      double bottom = _rect.bottom;

      if (alignment == Alignment.topLeft) {
        left += delta.dx;
        top += delta.dy;
      } else if (alignment == Alignment.topRight) {
        right += delta.dx;
        top += delta.dy;
      } else if (alignment == Alignment.bottomLeft) {
        left += delta.dx;
        bottom += delta.dy;
      } else if (alignment == Alignment.bottomRight) {
        right += delta.dx;
        bottom += delta.dy;
      }

      _rect = Rect.fromLTRB(
        left < right ? left : right,
        top < bottom ? top : bottom,
        left < right ? right : left,
        top < bottom ? bottom : top,
      );
    });

    widget.onUpdate(_rect);
  }

  Widget _buildCornerMarker(Alignment alignment) {
    return Positioned(
      left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
          ? _rect.left - 6
          : _rect.right - 6,
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight
          ? _rect.top - 6
          : _rect.bottom - 6,
      child: GestureDetector(
        onPanUpdate: (details) => _updateCorner(details.delta, alignment),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: _rect,
          child: GestureDetector(
            onPanUpdate: widget.isEditable
                ? (details) => setState(() {
              _rect = _rect.shift(details.delta);
              widget.onUpdate(_rect);
            })
                : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                color: Colors.red.withOpacity(0.2),
              ),
            ),
          ),
        ),
        if (widget.isEditable) ...[
          _buildCornerMarker(Alignment.topLeft),
          _buildCornerMarker(Alignment.topRight),
          _buildCornerMarker(Alignment.bottomLeft),
          _buildCornerMarker(Alignment.bottomRight),
        ],
        if (!widget.isEditable)
          Positioned(
            left: _rect.right - 16,
            top: _rect.top - 16,
            child: GestureDetector(
              onTap: widget.onIconTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}
