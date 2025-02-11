import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFNavigationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PdfViewerController pdfViewerController;
  final bool isAnnotationMode;
  final VoidCallback onAnnotationModeChanged;

  const PDFNavigationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.pdfViewerController,
    required this.isAnnotationMode,
    required this.onAnnotationModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 60,
      right: 60,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(

              icon: const Icon(

                  Icons.arrow_back, color: Colors.white, ),
              onPressed: () {
                if (currentPage > 0) {
                  pdfViewerController.goToPage(
                    pageNumber: currentPage - 1,
                  );
                }
              },
            ),
            Text(
              '${currentPage } / $totalPages',
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                if (currentPage < totalPages - 1) {
                  pdfViewerController.goToPage(
                    pageNumber: currentPage + 1,
                  );
                }
              },
            ),
            // IconButton(
            //   icon: Icon(
            //     isAnnotationMode ? Icons.edit_off : Icons.edit,
            //     color: Colors.white,
            //   ),
            //   onPressed: onAnnotationModeChanged,
            // ),
          ],
        ),
      ),
    );
  }
}
