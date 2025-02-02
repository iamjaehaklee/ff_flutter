import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_overlay.dart';
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/draggable_page_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_page_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/input_annotation_bottom_sheet.dart';

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
  Rect? _selectedRect;
  bool _isPdfLoaded = false;
  int _targetPage = 0; // 🟡 추가: 이동할 대상 페이지 번호

  // 페이지별 저장된 주석 리스트
  Map<int, List<DocumentAnnotationModel>> _annotationsByPage = {};
  final AnnotationController _annotationController = Get.find<AnnotationController>();

  @override
  void initState() {
    super.initState();
    final FileViewController controller = Get.find<FileViewController>();
    controller.loadFile(
      'work_room_files',
      '${widget.workRoomId}/${widget.fileName}',
      widget.fileName,
    );
    // ✅ 주석 불러오기
    _annotationController.fetchAnnotations(widget.fileName);
  }

  void _toggleAnnotationMode() {
    setState(() {
      _isAnnotationMode = !_isAnnotationMode;

      if (_isAnnotationMode) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        const double defaultWidth = 200.0;
        const double defaultHeight = 150.0;

        _selectedRect = Rect.fromCenter(
          center: Offset(screenWidth / 2, screenHeight / 2),
          width: defaultWidth,
          height: defaultHeight,
        );
      } else {
        _selectedRect = null;
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _targetPage = page; // 🟡 추가: 이동할 페이지 번호 동기화

    });
  }


  void _saveAnnotation(String author, String text) async {
    if (_selectedRect != null) {
      bool success = await _annotationController.saveAnnotation(
        workRoomId: widget.workRoomId,
        fileName: widget.fileName,
        page: _currentPage,
        rect: _selectedRect!,
        text: text,
        imageBytes: null, // PDF 주석에서는 이미지 없음
      );

      if (success) {
        setState(() {
          _isAnnotationMode = false;
          _selectedRect = null;
        });
      } else {
        print("Failed to save annotation");
      }
    }
  }



  void _showAnnotationDetails(DocumentAnnotationModel annotation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Annotation by ${annotation.createdBy}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(annotation.content ?? ""),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final FileViewController controller = Get.find<FileViewController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      }

      if (controller.file.value == null) {
        return const Center(child: Text("File not found."));
      }

      final file = controller.file.value!;
      return Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PDFView(
                  key: _pdfViewKey,
                  filePath: file.path,
                  swipeHorizontal: false,
                  enableSwipe: false,
                  pageFling: false,
                  pageSnap: false,
                  onRender: (pages) => setState(() => _totalPages = pages ?? 0),
                  onPageChanged: (page, _) => _onPageChanged(page ?? 0),
                  onViewCreated: (controller) =>
                      setState(() => _pdfViewController = controller),
                ),


                _buildDraggablePageController(), // ✅ 함수 호출하여 적용


                if (_isAnnotationMode && _selectedRect != null)
                  AnnotationOverlay(
                    annotation: DocumentAnnotationModel(
                      id: "temp",
                      // 임시 ID (편집 모드에서는 저장되지 않음)
                      documentId: null,
                      parentFileStorageKey: widget.fileName,
                      workRoomId: widget.workRoomId,
                      annotationType: "highlight",
                      pageNumber: _currentPage,
                      x1: _selectedRect!.left,
                      y1: _selectedRect!.top,
                      x2: _selectedRect!.right,
                      y2: _selectedRect!.bottom,
                      isOcr: false,
                      ocrText: null,
                      content: null,
                      createdBy: "Current User",
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                    selectedRect: _selectedRect!,
                    isEditable: true,
                    onUpdate: (rect) => setState(() => _selectedRect = rect),
                    onIconTap: () {}, // 편집 모드에서는 아이콘 없음
                  ),
                if (_annotationsByPage.containsKey(_currentPage))
                  for (var annotation in _annotationsByPage[_currentPage]!)
                    AnnotationOverlay(
                      annotation: annotation,
                      selectedRect: Rect.fromLTRB(
                        annotation.x1 ?? 0.0,
                        annotation.y1 ?? 0.0,
                        annotation.x2 ?? 0.0,
                        annotation.y2 ?? 0.0,
                      ),
                      isEditable: false,
                      onUpdate: (rect) {},
                      // 읽기 모드에서는 크기 변경 불가
                      onIconTap: () => _showAnnotationDetails(annotation),
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
                              child:
                                  const Icon(Icons.close, color: Colors.white),
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
                                      onSave: (text) => _saveAnnotation(
                                          "Current User", text), // 타입 불일치 해결
                                    );
                                  },
                                );
                              },
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                          ],
                        )
                      : FloatingActionButton(
                          onPressed: _toggleAnnotationMode,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.add_comment,
                              color: Colors.white),
                        ),
                ),
              ],
            ),
          ),

          if (_pdfViewController != null)
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom / 2),
              child: PdfPageController(
                currentPage: _currentPage,
                totalPages: _totalPages,
                pdfViewController: _pdfViewController!,
              ),
            ),
        ],
      );
    });
  }

  void _moveToPage(int page) {
    // 🔴 추가: 특정 페이지로 이동하는 함수
    if (_pdfViewController != null && page >= 0 && page < _totalPages) {
      _pdfViewController!.setPage(page);
    }
  }

  double _getControllerPosition() { // ✅ 추가: 현재 페이지에 따라 컨트롤러의 세로 위치 계산
    if (_totalPages == 0) return MediaQuery.of(context).size.height * 0.3;
    double availableHeight = MediaQuery.of(context).size.height * 0.6; // 전체 높이의 60% 범위에서 이동
    return (availableHeight / (_totalPages - 1)) * _currentPage + MediaQuery.of(context).size.height * 0.2;
  }
  Widget _buildDraggablePageController() {
    if (_pdfViewController == null || _totalPages <= 1) return SizedBox.shrink();

    double availableHeight = MediaQuery.of(context).size.height
        - kToolbarHeight // AppBar 높이 제외
        - kBottomNavigationBarHeight // 하단 페이지 컨트롤러 제외
        - MediaQuery.of(context).padding.top // 상단 상태 바 제외
        - MediaQuery.of(context).padding.bottom / 2; // 하단 SafeArea 고려
    double bottomLimit = kBottomNavigationBarHeight + 16; // ✅ PdfPageController보다 내려가지 않도록 제한

    return Positioned(
      right: 16,
      child: DraggablePageController(
        pdfViewController: _pdfViewController!,
        currentPage: _currentPage,
        totalPages: _totalPages,
        availableHeight: availableHeight,
        bottomLimit: bottomLimit, // ✅ 하단 제한 추가
        onUpdate: (page) => setState(() => _targetPage = page),
        onRelease: (page) => _moveToPage(page),
      ),
    );
  }

}
