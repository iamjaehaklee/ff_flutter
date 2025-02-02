import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/opencv_utils.dart';
import 'package:legalfactfinder2025/core/utils/pdf_utils.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/annotation_page.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_overlay.dart';
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/draggable_page_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_page_controller.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/input_annotation_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';

class PDFFileViewScreen extends StatefulWidget {
  final String workRoomId;
  final String fileName;

  const PDFFileViewScreen({
    Key? key,
    required this.workRoomId,
    required this.fileName,
  }) : super(key: key);

  @override
  _PDFFileViewScreenState createState() => _PDFFileViewScreenState();
}

class _PDFFileViewScreenState extends State<PDFFileViewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey _pdfViewKey = GlobalKey();
  PDFViewController? _pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isAnnotationMode = false;
  List<Rect> _detectedParagraphs = [];
  Set<int> _selectedParagraphs = {};
  ui.Image? _currentPageImage;
  int _targetPage = 0; // 🟡 추가: 이동할 대상 페이지 번호

  final AnnotationController _annotationController =
      Get.find<AnnotationController>();
  final FileViewController _fileViewController = Get.find<FileViewController>();

  @override
  void initState() {
    super.initState();
    print("OpenCV version: ${cv.openCvVersion()}");

    _fileViewController.loadFile(
      'work_room_files',
      '${widget.workRoomId}/${widget.fileName}',
      widget.fileName,
    );
    _annotationController.fetchAnnotations(widget.fileName);
  }

  /// **Toggle Annotation Mode & Detect Paragraphs**
  void _toggleAnnotationMode() async {
    debugPrint("[DEBUG] Toggle Annotation Mode: Start");

    setState(() {
      debugPrint(
          "[DEBUG] Updating state: _isAnnotationMode = ${!_isAnnotationMode}");
      _isAnnotationMode = !_isAnnotationMode;
      _detectedParagraphs.clear();
      _selectedParagraphs.clear();
      debugPrint("[DEBUG] Cleared _detectedParagraphs and _selectedParagraphs");
    });

    if (_isAnnotationMode) {
      debugPrint(
          "[DEBUG] Annotation mode is ON. Proceeding with image processing...");

      final file = _fileViewController.file.value;
      if (file == null) {
        debugPrint("[ERROR] File is null. Aborting.");
        return;
      }

      debugPrint("[DEBUG] Converting PDF page to image...");
      ui.Image? pageImage =
          await PdfUtils.convertPdfPageToImage(file.path, _currentPage + 1);
      if (pageImage == null) {
        debugPrint("[ERROR] Failed to convert PDF page to image. Aborting.");
        return;
      }

      debugPrint("[DEBUG] PDF page successfully converted to image.");
      setState(() {
        _currentPageImage = pageImage;
        debugPrint(
            "[DEBUG] Updated _currentPageImage with the converted image.");
      });

      // // ✅ 임시 디렉토리에 파일 저장
      //
      // try {
      //   final directory = await getTemporaryDirectory();
      //   final tempFilePath = "${directory.path}/after_convertPdfPageToImage.png";
      //   final tempFile = File(tempFilePath);
      //   await tempFile.writeAsBytes(image.toByteData(), mode: FileMode.write, flush: true);
      //   debugPrint(
      //       "[DEBUG] Successfully saved the file to the temporary directory: $tempFilePath");
      // } on Exception catch (e) {
      //   // TODO
      //   debugPrint(
      //       "[DEBUG] Failed to save the file to the temporary directory: $e.");
      // }

      debugPrint("[DEBUG] Detecting paragraphs using OpenCV...");
      List<Rect> paragraphs = await detectParagraphs(pageImage);
      debugPrint(
          "[DEBUG] Paragraph detection completed. Found ${paragraphs.length} paragraphs.");

      setState(() {
        _detectedParagraphs = paragraphs;
        debugPrint(
            "[DEBUG] Updated _detectedParagraphs with detected paragraphs.");
      });
    } else {
      debugPrint("[DEBUG] Annotation mode is OFF. No further action required.");
    }

    debugPrint("[DEBUG] Toggle Annotation Mode: End");
  }

  /// **Convert OpenCV Rect to Flutter Rect**
  ui.Rect _toFlutterRect(cv.Rect cvRect) {
    return ui.Rect.fromLTWH(
      cvRect.x.toDouble(),
      cvRect.y.toDouble(),
      cvRect.width.toDouble(),
      cvRect.height.toDouble(),
    );
  }

  /// **Detect Paragraphs using OpenCV**
  /// **Detect Paragraphs using OpenCV**


  /// **Move to Specific Page**
  void _moveToPage(int page) {
    if (_pdfViewController != null && page >= 0 && page < _totalPages) {
      _pdfViewController!.setPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      if (_fileViewController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_fileViewController.errorMessage.isNotEmpty) {
        return Center(child: Text(_fileViewController.errorMessage.value));
      }

      if (_fileViewController.file.value == null) {
        return const Center(child: Text("File not found."));
      }

      final file = _fileViewController.file.value!;
      return Stack(
        children: [
          // Container(
          //   child: Row(
          //     children: [
          //       Expanded(child: const Text("Annotation")),
          //       // ✅ "Annotation" 텍스트 추가
          //       Switch(
          //         // ✅ Toggle Switch 추가
          //         value: _isAnnotationMode,
          //         onChanged: _toggleAnnotationMode,
          //       ),
          //     ],
          //   ),
          // ),
          PDFView(
            key: _pdfViewKey,
            filePath: file.path,
            swipeHorizontal: false,
            enableSwipe: false,
            pageFling: false,
            pageSnap: false,
            onRender: (pages) => setState(() => _totalPages = pages ?? 0),
            onPageChanged: (page, _) =>
                setState(() => _currentPage = page ?? 0),
            onViewCreated: (controller) =>
                setState(() => _pdfViewController = controller),
          ),
          _buildDraggablePageController(),
          if (_isAnnotationMode)
            ..._detectedParagraphs.asMap().entries.map(
                  (entry) => Positioned.fromRect(
                    rect: entry.value,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedParagraphs.contains(entry.key)
                              ? Colors.blue
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
          Positioned(
            bottom: 80,
            right: 16,
            child: _isAnnotationMode
                ? Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "Cancel",
                        backgroundColor: Colors.red,
                        onPressed: _toggleAnnotationMode,
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "Confirm",
                        backgroundColor: Colors.green,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return InputAnnotationBottomSheet(
                                onSave: (text) {
                                  // Handle saving annotation
                                  _toggleAnnotationMode();
                                },
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ],
                  )
                : FloatingActionButton(
                    onPressed: _toggleAnnotationMode,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add_comment, color: Colors.white),
                  ),
          ),
          if (_pdfViewController != null)
            Positioned(
              bottom: 0, // Adjust spacing
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom / 2,
                ),
                child: PdfPageController(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  pdfViewController: _pdfViewController!,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDraggablePageController() {
    if (_pdfViewController == null || _totalPages <= 1)
      return SizedBox.shrink();

    double availableHeight = MediaQuery.of(context).size.height -
        kToolbarHeight // AppBar 높이 제외
        -
        kBottomNavigationBarHeight // 하단 페이지 컨트롤러 제외
        -
        MediaQuery.of(context).padding.top // 상단 상태 바 제외
        -
        MediaQuery.of(context).padding.bottom / 2; // 하단 SafeArea 고려
    double bottomLimit =
        kBottomNavigationBarHeight + 16; // ✅ PdfPageController보다 내려가지 않도록 제한

    return Positioned(
      right: 16,
      child: DraggablePageController(
        pdfViewController: _pdfViewController!,
        currentPage: _currentPage,
        totalPages: _totalPages,
        availableHeight: availableHeight,
        bottomLimit: bottomLimit,
        // ✅ 하단 제한 추가
        onUpdate: (page) => setState(() => _targetPage = page),
        onRelease: (page) => _moveToPage(page),
      ),
    );
  }
}
