// import 'package:flutter/material.dart';
// import 'package:pdfrx/pdfrx.dart';
//
// class PDFViewWidget extends StatelessWidget {
//   final String filePath;
//   final Function(int) onPageChanged;
//   final Function(PdfViewerController) onViewCreated;
//
//   const PDFViewWidget({
//     Key? key,
//     required this.filePath,
//     required this.onPageChanged,
//     required this.onViewCreated,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return PdfViewer(
//       controller: PdfViewerController(),
//       document: PdfDocument.openFile(filePath),
//       onPageChanged: onPageChanged,
//       onControllerInitialized: onViewCreated,
//       scrollDirection: Axis.vertical,
//     );
//   }
// }
