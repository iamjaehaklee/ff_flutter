// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:developer';

// class TestPDFViewPage extends StatefulWidget {
//   @override
//   _TestPDFViewPageState createState() => _TestPDFViewPageState();
// }

// class _TestPDFViewPageState extends State<TestPDFViewPage> {
//   bool isDrawingEnabled = false;
//   List<Map<String, dynamic>> drawnRectangles = []; // 모든 페이지의 사각형 저장
//   Rect? tempRectangle;
//   Offset? startDrag;
//   PDFViewController? pdfViewController;
//   String pdfPath = "";
//   int currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     log("TestPDFViewPage initialized");
//     _loadPdfFromAssets("assets/test/test.pdf").then((path) {
//       setState(() {
//         pdfPath = path;
//         log("PDF loaded from assets: $pdfPath");
//       });
//     }).catchError((error) {
//       log("Error loading PDF: $error");
//     });
//   }

//   Future<String> _loadPdfFromAssets(String assetPath) async {
//     try {
//       var dir = await getApplicationDocumentsDirectory();
//       File file = File("${dir.path}/temp.pdf");
//       var data = await rootBundle.load(assetPath);
//       var bytes = data.buffer.asUint8List();
//       await file.writeAsBytes(bytes, flush: true);
//       return file.path;
//     } catch (e) {
//       throw Exception('Error parsing asset file: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     log("Building TestPDFViewPage UI");
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("PDF Viewer"),
//         actions: [
//           IconButton(
//             icon: Icon(isDrawingEnabled ? Icons.edit_off : Icons.edit),
//             onPressed: () {
//               setState(() {
//                 isDrawingEnabled = !isDrawingEnabled;
//                 log("Drawing mode toggled: $isDrawingEnabled");
//               });
//             },
//           )
//         ],
//       ),
//       body: pdfPath.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GestureDetector(
//             onPanStart: isDrawingEnabled
//                 ? (details) {
//               log("Pan started at: ${details.localPosition}");
//               setState(() {
//                 startDrag = details.localPosition;
//               });
//             }
//                 : null,
//             onPanUpdate: isDrawingEnabled
//                 ? (details) {
//               log("Pan updated at: ${details.localPosition}");
//               setState(() {
//                 if (startDrag != null) {
//                   tempRectangle = Rect.fromPoints(
//                       startDrag!, details.localPosition);
//                 }
//               });
//             }
//                 : null,
//             onPanEnd: isDrawingEnabled
//                 ? (details) {
//               log("Pan ended");
//               setState(() {
//                 if (tempRectangle != null) {
//                   drawnRectangles.add({
//                     "rect": tempRectangle!,
//                     "page": currentPage
//                   });
//                   log("Rectangle added: $tempRectangle on page: $currentPage");
//                   tempRectangle = null;
//                 }
//               });
//             }
//                 : null,
//             child: PDFView(
//               filePath: pdfPath,
//               enableSwipe: true,
//               swipeHorizontal: false,
//               autoSpacing: true,
//               pageFling: true,
//               onViewCreated: (controller) {
//                 log("PDFView created");
//                 pdfViewController = controller;
//               },
//               onPageChanged: (page, total) {
//                 log("PDF page changed: $page/$total");
//                 setState(() {
//                   currentPage = page ?? 0;
//                 });
//               },
//               onError: (error) {
//                 log("PDF error: $error");
//               },
//             ),
//           ),
//           // 현재 페이지에 해당하는 사각형만 그리기
//           ...drawnRectangles
//               .where((rectData) => rectData["page"] == currentPage)
//               .map((rectData) {
//             final rect = rectData["rect"];
//             if (rect is Rect) {
//               return Positioned(
//                 left: rect.left,
//                 top: rect.top,
//                 width: rect.width,
//                 height: rect.height,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.red, width: 2),
//                   ),
//                 ),
//               );
//             } else {
//               log("Invalid rectangle data: $rectData");
//               return SizedBox();
//             }
//           }).toList(),
//           // 임시 사각형 그리기
//           if (tempRectangle != null)
//             Positioned(
//               left: tempRectangle!.left,
//               top: tempRectangle!.top,
//               width: tempRectangle!.width,
//               height: tempRectangle!.height,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue, width: 2),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }