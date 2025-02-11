// // lib/features/files/presentation/widgets/pdf_viewer_widget.dart
// import 'package:flutter/material.dart';
// import 'package:pdfrx/pdfrx.dart';
//
// class PDFViewerWidget extends StatelessWidget {
//   final String filePath;
//   final Function(int) onPageChanged;
//   final Function(int?) onRender;
//   final Function(PdfViewerController) onViewCreated;
//
//   const PDFViewerWidget({
//     Key? key,
//     required this.filePath,
//     required this.onPageChanged,
//     required this.onRender,
//     required this.onViewCreated,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return PdfViewer(
//       controller: PdfViewerController(),
//       document: PdfDocument.openFile(filePath),
//       onDocumentLoaded: (document) => onRender(document.pageCount),
//       onPageChanged: onPageChanged,
//       onControllerInitialized: onViewCreated,
//       scrollDirection: Axis.vertical,
//     );
//   }
// }
