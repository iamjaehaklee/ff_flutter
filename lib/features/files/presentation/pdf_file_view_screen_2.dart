// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:get/get.dart';
// import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/input_annotation_bottom_sheet.dart';
// import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_overlay_painter.dart';
// import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_overlay_wrapper.dart';
// import 'package:pdfrx/pdfrx.dart';
// import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
// import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
// import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_search_widget.dart';
// import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_annotation_widget.dart';
// import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_navigation_widget.dart';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'dart:math' as math;
//
// class PDFFileViewScreen extends StatefulWidget {
//   final String workRoomId;
//   final String fileName;
//
//   const PDFFileViewScreen({
//     Key? key,
//     required this.workRoomId,
//     required this.fileName,
//   }) : super(key: key);
//
//   @override
//   State<PDFFileViewScreen> createState() => _PDFFileViewScreenState();
// }
//
// class _PDFFileViewScreenState extends State<PDFFileViewScreen>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;
//
//   final AnnotationController _annotationController =
//   Get.find<AnnotationController>();
//   final FileViewController _fileViewController = Get.find<FileViewController>();
//   late final PdfViewerController _pdfViewerController;
//   late final PdfTextSearcher _pdfTextSearcher;
//
//   final GlobalKey _pdfViewKey = GlobalKey();
//   final GlobalKey _captureBoundaryKey = GlobalKey();
//   // 🔵 annotation 모드에서 캡쳐된 페이지 이미지 위젯의 크기를 측정하기 위한 key
//   final GlobalKey _annotationBoundaryKey = GlobalKey();
//   int _currentPage = 0;
//   int _totalPages = 0;
//   bool _isAnnotationMode = false;
//   Rect _selectionArea = Rect.zero;
//   Uint8List? _capturedImage;
//   // 🔵 캡쳐된 페이지 이미지의 원본 크기 (ui.Image 기준)
//   Size? _capturedImageSize;
//
//   @override
//   void initState() {
//     super.initState();
//     _pdfViewerController = PdfViewerController();
//     _pdfTextSearcher = PdfTextSearcher(_pdfViewerController)
//       ..addListener(_updateSearch);
//     _fileViewController.loadFile(
//       'work_room_files',
//       '${widget.workRoomId}/${widget.fileName}',
//       widget.fileName,
//     );
//     _annotationController.fetchAnnotations(widget.fileName);
//   }
//
//   void _updateSearch() {
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   @override
//   void dispose() {
//     _pdfTextSearcher.removeListener(_updateSearch);
//     _pdfTextSearcher.dispose();
//     super.dispose();
//   }
//
//   // 🔵 수정: annotation mode 진입 시 현재 페이지 한 장만 직접 렌더링하여 캡쳐된 이미지로 사용
//   Future<void> _toggleAnnotationMode() async {
//     setState(() {
//       _isAnnotationMode = !_isAnnotationMode;
//       if (_isAnnotationMode) {
//         _initializeSelectionArea();
//       } else {
//         _selectionArea = Rect.zero;
//         _capturedImage = null; // 모드 종료 시 이미지 초기화
//       }
//     });
//     if (_isAnnotationMode) {
//       await _captureCurrentPageImage(); // 🔵 직접 렌더링 API 호출
//     }
//   }
//
//
// // 🔵 수정된 _captureCurrentPageImage() 함수: PdfDocument의 현재 페이지를 render() 후 ui.Image로 변환하고, PNG로 인코딩
//   Future<void> _captureCurrentPageImage() async {
//     try {
//       final doc = await PdfDocument.openFile(_fileViewController.file.value!.path);
//       final int pageNumber = _currentPage;
//       // 🔵 doc.pages 리스트에서 현재 페이지를 가져옴 (1-based)
//       final page = doc.pages[pageNumber - 1];
//       double scale = 3.0;
//       final pdfImage = await page.render(
//         fullWidth: page.width * scale,
//         fullHeight: page.height * scale,
//         backgroundColor: Colors.white,
//         annotationRenderingMode: PdfAnnotationRenderingMode.annotationAndForms,
//       );
//       if (pdfImage == null) {
//         debugPrint('🔵 Error: Render returned null.');
//         return;
//       }
//       // 🔵 ui.Image 생성 및 PNG 인코딩
//       final ui.Image renderedImage = await pdfImage.createImage();
//       // 🔵 원본 이미지 크기 저장
//       _capturedImageSize = Size(renderedImage.width.toDouble(), renderedImage.height.toDouble());
//       final ByteData? pngData =
//       await renderedImage.toByteData(format: ui.ImageByteFormat.png);
//       if (pngData == null) {
//         debugPrint('🔵 Error: Failed to convert rendered image to PNG bytes.');
//         return;
//       }
//       setState(() {
//         _capturedImage = pngData.buffer.asUint8List();
//       });
//       debugPrint('🔵 Current page image captured for annotation mode.');
//       pdfImage.dispose();
//       await doc.dispose();
//     } catch (e, stackTrace) {
//       debugPrint("🔵 Error capturing current page image: $e");
//       debugPrint("$stackTrace");
//     }
//   }
//
//
//   // 🔵 추가: 현재 PDF 뷰어 위젯 전체를 이미지로 캡쳐하는 함수
//   Future<void> _captureFullPDFImage() async {
//     try {
//       final boundary = _captureBoundaryKey.currentContext?.findRenderObject()
//       as RenderRepaintBoundary?;
//       if (boundary == null) {
//         debugPrint('🔵 Error: RenderRepaintBoundary not found.');
//         return;
//       }
//       await Future.delayed(const Duration(milliseconds: 100));
//       final ui.Image fullImage = await boundary.toImage(pixelRatio: 3.0);
//       final ByteData? byteData =
//       await fullImage.toByteData(format: ui.ImageByteFormat.png);
//       if (byteData == null) {
//         debugPrint('🔵 Error: Failed to convert image to byte data.');
//         return;
//       }
//       setState(() {
//         _capturedImage = byteData.buffer.asUint8List();
//       });
//       debugPrint('🔵 Full PDF image captured for annotation mode.');
//     } catch (e, stackTrace) {
//       debugPrint("🔵 Error capturing full PDF image: $e");
//       debugPrint("$stackTrace");
//     }
//   }
//
//
//   void _initializeSelectionArea() {
//     // 🔵 초기 선택 영역을 컨테이너 전체 중앙 (나중에 클램핑 적용됨)
//     final size = MediaQuery.of(context).size;
//     final center = Offset(size.width / 2, size.height / 2);
//     final width = size.width * 0.8;
//     final height = size.height * 0.4;
//     setState(() {
//       _selectionArea = Rect.fromCenter(center: center, width: width, height: height);
//     });
//   }
//
// // 좌표를 정규화하여 항상 양수의 width와 height를 갖도록 하는 함수
//   Rect normalizeRect(Rect rect) {
//     return Rect.fromLTRB(
//       math.min(rect.left, rect.right),
//       math.min(rect.top, rect.bottom),
//       math.max(rect.left, rect.right),
//       math.max(rect.top, rect.bottom),
//     );
//   }
//
//   // 🔵 선택 영역이 실제 이미지 내에서 벗어나지 않도록 클램핑하는 함수 (BoxFit.contain 적용 시)
//   Rect _clampSelectionArea(Rect selection) {
//     final RenderBox renderBox = _annotationBoundaryKey.currentContext!.findRenderObject() as RenderBox;
//     final containerSize = renderBox.size;
//     if (_capturedImageSize == null) return selection;
//     final imageSize = _capturedImageSize!;
//     final imageAspect = imageSize.width / imageSize.height;
//     final containerAspect = containerSize.width / containerSize.height;
//     double displayedWidth, displayedHeight, offsetX, offsetY;
//     if (containerAspect > imageAspect) {
//       // container가 더 넓은 경우: 수직 꽉참
//       displayedHeight = containerSize.height;
//       displayedWidth = displayedHeight * imageAspect;
//       offsetX = (containerSize.width - displayedWidth) / 2;
//       offsetY = 0;
//     } else {
//       displayedWidth = containerSize.width;
//       displayedHeight = displayedWidth / imageAspect;
//       offsetX = 0;
//       offsetY = (containerSize.height - displayedHeight) / 2;
//     }
//     final double left = selection.left < offsetX ? offsetX : selection.left;
//     final double top = selection.top < offsetY ? offsetY : selection.top;
//     final double right = selection.right > offsetX + displayedWidth ? offsetX + displayedWidth : selection.right;
//     final double bottom = selection.bottom > offsetY + displayedHeight ? offsetY + displayedHeight : selection.bottom;
//     return Rect.fromLTRB(left, top, right, bottom);
//   }
//
//   // 🔵 수정: _captureSelectedArea() 함수에서 실제 이미지의 letterboxed 영역을 고려하여 선택 영역 좌표 변환
//   Future<void> _captureSelectedArea() async {
//     try {
//       if (_selectionArea.isEmpty) {
//         debugPrint('Error: No selection area defined.');
//         return;
//       }
//       if (_capturedImage == null || _capturedImageSize == null) {
//         debugPrint('🔵 Error: Captured image is not available.');
//         return;
//       }
//       final normalizedSelection = normalizeRect(_selectionArea);
//
//       // _annotationBoundaryKey 컨테이너 크기
//       final RenderBox renderBox = _annotationBoundaryKey.currentContext!.findRenderObject() as RenderBox;
//       final containerSize = renderBox.size;
//
//       // 🔵 캡쳐된 이미지 원본 크기
//       final imageSize = _capturedImageSize!;
//       final imageAspect = imageSize.width / imageSize.height;
//       final containerAspect = containerSize.width / containerSize.height;
//
//       double displayedWidth, displayedHeight, offsetX, offsetY;
//       if (containerAspect > imageAspect) {
//         displayedHeight = containerSize.height;
//         displayedWidth = displayedHeight * imageAspect;
//         offsetX = (containerSize.width - displayedWidth) / 2;
//         offsetY = 0;
//       } else {
//         displayedWidth = containerSize.width;
//         displayedHeight = displayedWidth / imageAspect;
//         offsetX = 0;
//         offsetY = (containerSize.height - displayedHeight) / 2;
//       }
//
//       // 🔵 선택 영역을 먼저 클램핑
//       final clampedSelection = _clampSelectionArea(normalizedSelection);
//       // 🔵 선택 영역에서 letterbox offset을 제거 (즉, 실제 이미지 내 좌표)
//       final Rect adjustedSelection = Rect.fromLTWH(
//         clampedSelection.left - offsetX,
//         clampedSelection.top - offsetY,
//         clampedSelection.width,
//         clampedSelection.height,
//       );
//
//       // 🔵 스케일: 실제 이미지 크기 / displayed 이미지 크기
//       final double scaleX = imageSize.width / displayedWidth;
//       final double scaleY = imageSize.height / displayedHeight;
//
//       final Rect imageSelection = Rect.fromLTWH(
//         adjustedSelection.left * scaleX,
//         adjustedSelection.top * scaleY,
//         adjustedSelection.width * scaleX,
//         adjustedSelection.height * scaleY,
//       );
//
//       if (imageSelection.width <= 0 || imageSelection.height <= 0) {
//         debugPrint(
//             "🔵 Error: Invalid image dimensions (width: ${imageSelection.width}, height: ${imageSelection.height})");
//         return;
//       }
//
//       final ui.Image fullImage = await decodeImageFromList(_capturedImage!);
//       final recorder = ui.PictureRecorder();
//       final canvas = Canvas(recorder);
//       canvas.drawImageRect(
//         fullImage,
//         imageSelection,
//         Rect.fromLTWH(0, 0, imageSelection.width, imageSelection.height),
//         Paint(),
//       );
//
//       final croppedImage = await recorder
//           .endRecording()
//           .toImage(imageSelection.width.toInt(), imageSelection.height.toInt());
//       final ByteData? croppedByteData =
//       await croppedImage.toByteData(format: ui.ImageByteFormat.png);
//
//       if (croppedByteData != null) {
//         final Uint8List croppedBytes = croppedByteData.buffer.asUint8List();
//         debugPrint("🔵 Cropped image captured successfully");
//
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           builder: (context) => InputAnnotationBottomSheet(
//             image: croppedBytes,
//             onSave: (text) => _toggleAnnotationMode(),
//           ),
//         );
//       } else {
//         debugPrint("🔵 Error: Failed to convert cropped image to byte data.");
//       }
//     } catch (e, stackTrace) {
//       debugPrint("🔵 Error capturing selected area: $e");
//       debugPrint("$stackTrace");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Obx(() {
//       if (_fileViewController.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (_fileViewController.errorMessage.isNotEmpty) {
//         return Center(child: Text(_fileViewController.errorMessage.value));
//       }
//       if (_fileViewController.file.value == null) {
//         return const Center(child: Text("File not found."));
//       }
//
//       return Stack(
//         children: [
//           RepaintBoundary(
//             key: _captureBoundaryKey,
//             child: PdfViewer(
//               key: _pdfViewKey, // 여기서 키 할당
//
//               PdfDocumentRefFile(_fileViewController.file.value!.path),
//               controller: _pdfViewerController,
//               params: PdfViewerParams(
//                 scaleEnabled: _isAnnotationMode ? false : true,
//
//                 panEnabled: _isAnnotationMode ? false : true,
//                 enableTextSelection: _isAnnotationMode ? false : true,
//                 pagePaintCallbacks: [
//                   _pdfTextSearcher.pageTextMatchPaintCallback,
//                 ],
//
//                 /// ✅ onViewerReady 콜백을 사용하여 총 페이지 수 가져오기
//                 onViewerReady: (document, controller) {
//                   setState(() {
//                     _totalPages = document.pages.length;
//                   });
//                   debugPrint("PDFFileViewScreen: 총 페이지 수 $_totalPages 로드 완료");
//                 },
//                 onPageChanged: (page) {
//                   setState(() => _currentPage = page ?? 0);
//                 },
//                 viewerOverlayBuilder: (context, size, handleLinkTap) => [
//                   // Add vertical scroll thumb on viewer's right side
//
//                   Visibility(
//                     visible: !_isAnnotationMode,
//                     child: PdfViewerScrollThumb(
//                       controller: _pdfViewerController,
//                       orientation: ScrollbarOrientation.right,
//                       thumbSize: const Size(40, 25),
//                       thumbBuilder:
//                           (context, thumbSize, pageNumber, controller) =>
//                           Container(
//                             color: Colors.black,
//                             // Show page number on the thumb
//                             child: Center(
//                               child: Text(
//                                 pageNumber.toString(),
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // 🔵 annotation mode 시, PDFViewer 위에 음영 오버레이 적용 (배경)
//           if (_isAnnotationMode)
//             Positioned.fill(
//               child: Container(color: Colors.black.withOpacity(0.5)),
//             ),
//
//
//
//           if (!_isAnnotationMode) ...[
//             PDFSearchWidget(
//               pdfTextSearcher: _pdfTextSearcher,
//               pdfViewerController: _pdfViewerController,
//             ),
//             Positioned(
//               top: 80,
//               left: 16,
//               child: GestureDetector(
//                 onTap: _toggleAnnotationMode,
//                 child: Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.add_comment_outlined),
//                 ),
//               ),
//             ),
//             PDFNavigationWidget(
//               currentPage: _currentPage,
//               totalPages: _totalPages,
//               pdfViewerController: _pdfViewerController,
//               isAnnotationMode: _isAnnotationMode,
//               onAnnotationModeChanged: _toggleAnnotationMode,
//             ),
//           ],
//           // 🔵 annotation mode 시, 캡쳐된 "현재 페이지" 이미지가 있으면 이를 전체로 표시
//           if (_isAnnotationMode && _capturedImage != null)
//             Positioned.fill(
//               child: RepaintBoundary(
//                 key: _annotationBoundaryKey,
//                 child: Image.memory(
//                   _capturedImage!,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           // 🔵 annotation mode UI: 위 캡쳐 이미지 위에 영역 선택 overlay 및 하단 버튼
//           if (_isAnnotationMode)
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: AnnotationOverlayWrapper(
//                       selectionArea: _selectionArea,
//                       isEditable: true,
//                       // 🔵 onUpdate 콜백에서 선택 영역을 클램핑하여 업데이트
//                       onUpdate: (newRect) {
//                         setState(() {
//                           _selectionArea = _clampSelectionArea(newRect);
//                         });
//                       },
//                       onIconTap: _toggleAnnotationMode,
//                     ),
//                   ),
//                   Container(
//                     color: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         SizedBox(
//                           width: 140,
//                           child: TextButton(
//                             onPressed: _toggleAnnotationMode,
//                             child: const Text("Cancel"),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 140,
//                           child: ElevatedButton(
//                             onPressed: _captureSelectedArea,
//                             child: const Text("Write comment"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }
