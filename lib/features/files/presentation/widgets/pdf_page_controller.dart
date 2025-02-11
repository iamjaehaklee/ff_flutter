import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfPageController extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PdfViewerController pdfViewController;

  const PdfPageController({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.pdfViewController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => pdfViewController.goToPage(
                pageNumber: (currentPage - 1).clamp(0, totalPages - 1)),
          ),
          Text(
            "${currentPage + 1} / $totalPages",
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => pdfViewController.goToPage(
                pageNumber: (currentPage + 1).clamp(0, totalPages - 1)),
          ),
        ],
      ),
    );
  }
}
