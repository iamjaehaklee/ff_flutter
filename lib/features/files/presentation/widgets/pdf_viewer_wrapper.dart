// File: lib/widgets/pdf_viewer_wrapper.dart
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

typedef ViewerReadyCallback = void Function(int totalPages);
typedef PageChangedCallback = void Function(int? page);

class PdfViewerWrapper extends StatelessWidget {
  final GlobalKey captureBoundaryKey;
  final GlobalKey pdfViewKey;
  final String filePath;
  final PdfViewerController pdfViewerController;
  final PdfTextSearcher pdfTextSearcher;
  final ViewerReadyCallback onViewerReady;
  final PageChangedCallback onPageChanged;

  const PdfViewerWrapper({
    Key? key,
    required this.captureBoundaryKey,
    required this.pdfViewKey,
    required this.filePath,
    required this.pdfViewerController,
    required this.pdfTextSearcher,
    required this.onViewerReady,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: captureBoundaryKey,
      child: PdfViewer(
        key: pdfViewKey,
        PdfDocumentRefFile(filePath),
        controller: pdfViewerController,
        params: PdfViewerParams(
          scaleEnabled: true,
          panEnabled: true,
          enableTextSelection: true,
          pagePaintCallbacks: [
            pdfTextSearcher.pageTextMatchPaintCallback,
          ],
          onViewerReady: (document, controller) {
            onViewerReady(document.pages.length);
          },
          onPageChanged: (page) {
            onPageChanged(page);
          },
          viewerOverlayBuilder: (context, size, handleLinkTap) => [
            Visibility(
              child: PdfViewerScrollThumb(
                controller: pdfViewerController,
                orientation: ScrollbarOrientation.right,
                thumbSize: const Size(40, 25),
                thumbBuilder: (context, thumbSize, pageNumber, controller) => Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      pageNumber.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
// End of PdfViewerWrapper class
}
