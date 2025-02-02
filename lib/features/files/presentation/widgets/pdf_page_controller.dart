import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfPageController extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PDFViewController pdfViewController;

  const PdfPageController({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.pdfViewController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => pdfViewController.setPage(currentPage - 1),
          ),
          Text(
            "${currentPage + 1} / $totalPages",
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => pdfViewController.setPage(currentPage + 1),
          ),
        ],
      ),
    );
  }
}
