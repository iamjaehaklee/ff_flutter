import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class DraggablePageController extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final double availableHeight;
  final double bottomLimit;
  final Function(int) onUpdate;
  final Function(int) onRelease;
  final PdfViewerController pdfViewController;

  const DraggablePageController({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.availableHeight,
    required this.bottomLimit,
    required this.onUpdate,
    required this.onRelease,
    required this.pdfViewController,
  }) : super(key: key);

  @override
  _DraggablePageControllerState createState() =>
      _DraggablePageControllerState();
}

class _DraggablePageControllerState extends State<DraggablePageController> {
  double _currentY = 0;
  int _displayPage = 0;
  double _startY = 0;

  @override
  void initState() {
    super.initState();
    _updateControllerPosition();
  }

  @override
  void didUpdateWidget(covariant DraggablePageController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _updateControllerPosition();
    }
  }

  void _updateControllerPosition() {
    setState(() {
      if (widget.totalPages > 1) {
        _currentY = (widget.availableHeight / (widget.totalPages - 1)) * widget.currentPage;
        _displayPage = widget.currentPage;
      }
    });
  }

  int _calculatePageFromPosition(double position) {
    return ((position / widget.availableHeight) * (widget.totalPages - 1))
        .round()
        .clamp(0, widget.totalPages - 1);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _startY = details.globalPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      double newPosition = _currentY + details.delta.dy;
      newPosition = newPosition.clamp(0, widget.availableHeight - widget.bottomLimit);
      _currentY = newPosition;
      _displayPage = _calculatePageFromPosition(_currentY);
      widget.onUpdate(_displayPage);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    widget.onRelease(_displayPage);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      top: _currentY,
      child: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_displayPage + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
