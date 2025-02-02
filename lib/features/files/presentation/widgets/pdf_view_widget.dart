import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewWidget extends StatelessWidget {
  final String filePath;
  final Function(int) onPageChanged;
  final Function(PDFViewController) onViewCreated;

  const PDFViewWidget({
    Key? key,
    required this.filePath,
    required this.onPageChanged,
    required this.onViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: filePath,
      swipeHorizontal: false,
      enableSwipe: false,
      pageFling: false,
      pageSnap: false,
      onPageChanged: (page, _) => onPageChanged(page ?? 0),
      onViewCreated: onViewCreated,
    );
  }
}
