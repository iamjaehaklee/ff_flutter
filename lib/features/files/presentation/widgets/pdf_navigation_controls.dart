// File: lib/widgets/pdf_navigation_controls.dart
import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_search_widget.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_navigation_widget.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/foundation.dart';


class PdfNavigationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onToggleAnnotationMode;
  final PdfViewerController pdfViewerController;
  final PdfTextSearcher pdfTextSearcher;

  const PdfNavigationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onToggleAnnotationMode,
    required this.pdfViewerController,
    required this.pdfTextSearcher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PDFSearchWidget(
          pdfTextSearcher: pdfTextSearcher,
          pdfViewerController: pdfViewerController,
        ),
        Positioned(
          top: 80,
          left: 16,
          child: GestureDetector(
            onTap: onToggleAnnotationMode,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add_comment_outlined),
            ),
          ),
        ),
        PDFNavigationWidget(
          currentPage: currentPage,
          totalPages: totalPages,
          pdfViewerController: pdfViewerController,
          isAnnotationMode: false,
          onAnnotationModeChanged: onToggleAnnotationMode,
        ),
      ],
    );
  }
// End of PdfNavigationControls class
}
