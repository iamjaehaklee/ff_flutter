import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TestSyncfusionPdfFileViewPage extends StatefulWidget {
  const TestSyncfusionPdfFileViewPage({super.key});

  @override
  _TestSyncfusionPdfFileViewPageState createState() => _TestSyncfusionPdfFileViewPageState();
}

class _TestSyncfusionPdfFileViewPageState extends State<TestSyncfusionPdfFileViewPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController _pdfController = PdfViewerController();
  bool _isCommentMode = false;
  bool _pdfScrollable = true;
  Rect? _selectedRegion;
  int? _selectedPage;
  final List<CommentBox> _commentBoxes = [];

  @override
  void initState() {
    super.initState();
    _pdfController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Listener(
            onPointerMove: _pdfScrollable ? null : (event) {},
            child: SfPdfViewer.network(
              'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
              key: _pdfViewerKey,
              controller: _pdfController,
              interactionMode: _pdfScrollable ? PdfInteractionMode.selection : PdfInteractionMode.pan,
              onTap: (details) {
                if (_isCommentMode) {
                  int currentPage = _pdfController.pageNumber;
                  setState(() {
                    _selectedRegion = Rect.fromLTWH(
                      details.position.dx,
                      details.position.dy,
                      100,
                      50,
                    );
                    _selectedPage = currentPage;
                  });
                }
              },
            ),
          ),
          if (_isCommentMode && _selectedRegion != null && _selectedPage != null)
            Positioned(
              left: _selectedRegion!.left,
              top: _selectedRegion!.top,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _selectedRegion = _selectedRegion!.translate(details.delta.dx, details.delta.dy);
                  });
                },
                child: Container(
                  width: _selectedRegion!.width,
                  height: _selectedRegion!.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    color: Colors.red.withOpacity(0.2),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add_comment, color: Colors.white),
                      onPressed: () => _addCommentDialog(_selectedPage!, _selectedRegion!),
                    ),
                  ),
                ),
              ),
            ),
          for (final commentBox in _commentBoxes.where((c) => c.pageNumber == _pdfController.pageNumber))
            Positioned(
              left: commentBox.rect.left,
              top: commentBox.rect.top,
              child: GestureDetector(
                onTap: () => _showComment(commentBox.comment),
                child: Container(
                  width: commentBox.rect.width,
                  height: commentBox.rect.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  child: const Center(child: Icon(Icons.comment, color: Colors.white)),
                ),
              ),
            ),
          Positioned(
            right: 20,
            top: 20,
            child: FloatingActionButton(
              child: Icon(_isCommentMode ? Icons.close : Icons.mode_comment),
              onPressed: () {
                setState(() {
                  _isCommentMode = !_isCommentMode;
                  _pdfScrollable = !_isCommentMode;
                  _selectedRegion = null;
                  _selectedPage = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addCommentDialog(int pageNumber, Rect position) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter your comment')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (controller.text.isNotEmpty) {
                    _commentBoxes.add(CommentBox(
                      pageNumber,
                      position,
                      controller.text,
                    ));
                  }
                  _selectedRegion = null;
                  _isCommentMode = false;
                  _pdfScrollable = true;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showComment(String comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Comment'),
          content: Text(comment),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CommentBox {
  final int pageNumber;
  final Rect rect;
  final String comment;

  CommentBox(this.pageNumber, this.rect, this.comment);
}
