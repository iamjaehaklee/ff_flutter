// File: lib/screens/pdf_file_view_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/widgets/custom_bottom_sheet.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_input_form.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_list_view.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_mode_controls.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_mode_overlay.dart';
import 'package:legalfactfinder2025/features/document_annotation/services/pdf_image_capture_service.dart';
import 'package:legalfactfinder2025/features/document_annotation/utils/pdf_file_view_state_helpers.dart';
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_navigation_controls.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/pdf_viewer_wrapper.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart';

class PDFFileViewScreen extends StatefulWidget {
  final String workRoomId;
  final String fileName;
  final String storageKey;
  final WorkRoomWithParticipants workRoomWithParticipants;

  const PDFFileViewScreen({
    Key? key,
    required this.workRoomId,
    required this.fileName,
    required this.storageKey,
    required this.workRoomWithParticipants,

  }) : super(key: key);

  @override
  State<PDFFileViewScreen> createState() => _PDFFileViewScreenState();
}

class _PDFFileViewScreenState extends State<PDFFileViewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final AnnotationController _annotationController =
      Get.find<AnnotationController>();
  final FileViewController _fileViewController = Get.find<FileViewController>();

  // Global keys
  final GlobalKey pdfViewKey = GlobalKey();
  final GlobalKey captureBoundaryKey = GlobalKey();

  // 🔵 _annotationBoundaryKey: annotation 모드에서 캡쳐된 페이지 이미지 위젯 크기 측정을 위한 GlobalKey
  final GlobalKey annotationBoundaryKey = GlobalKey();

  late final PdfViewerController _pdfViewerController;
  late final PdfTextSearcher _pdfTextSearcher;

  int _currentPage = 0;
  int _totalPages = 0;
  bool _isAnnotationMode = false;
  Rect _selectionArea = Rect.zero;
  Uint8List? _capturedImage;

  // 🔵 _capturedImageSize: 캡쳐된 페이지 이미지의 원본 크기 (ui.Image 기준)
  ui.Size? _capturedImageSize;



  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _pdfTextSearcher = PdfTextSearcher(_pdfViewerController)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _fileViewController.loadFile(
      'work_room_files',
      '${widget.workRoomId}/${widget.fileName}',
      widget.fileName,
    );
    _annotationController
        .fetchAnnotationsByParentFileStorageKey(widget.storageKey);
  }

  @override
  void dispose() {
    _pdfTextSearcher.removeListener(() {});
    _pdfTextSearcher.dispose();
    super.dispose();
  }

  // 🟢 _toggleAnnotationMode(): annotation mode 진입/종료 시 상태 및 캡쳐 이미지 초기화 처리
  Future<void> _toggleAnnotationMode() async {
    setState(() {
      _isAnnotationMode = !_isAnnotationMode;
      if (_isAnnotationMode) {
        _selectionArea = initializeSelectionArea(context);
      } else {
        _selectionArea = Rect.zero;
        _capturedImage = null;
        _capturedImageSize = null;
      }
    });
    if (_isAnnotationMode) {
      final result = await PdfImageCaptureService.captureCurrentPageImage(
          _fileViewController.file.value!.path, _currentPage);
      if (result != null) {
        setState(() {
          _capturedImage = result.image;
          _capturedImageSize = result.size;
        });
      }
    }
  } // End of _toggleAnnotationMode() 🟢

  // 🟣 _captureSelectedArea(): 실제 이미지의 letterboxed 영역을 고려하여 선택 영역 좌표 변환 후 크롭
  Future<void> _captureSelectedArea() async {
    try {
      if (_selectionArea.isEmpty) {
        debugPrint('Error: No selection area defined.');
        return;
      }
      if (_capturedImage == null || _capturedImageSize == null) {
        debugPrint('🟣 Error: Captured image is not available.');
        return;
      }
      // obtain container size from annotationBoundaryKey
      final RenderBox box =
          annotationBoundaryKey.currentContext!.findRenderObject() as RenderBox;
      final containerSize = box.size;
      final Uint8List? croppedBytes = await captureSelectedArea(
        selectionArea: _selectionArea,
        capturedImage: _capturedImage!,
        capturedImageSize:
            ui.Size(_capturedImageSize!.width, _capturedImageSize!.height),
        containerSize: containerSize,
      );
      if (croppedBytes != null) {
        debugPrint("🟣 Cropped image captured successfully");
        _showAnnotationInputBottomSheet(croppedBytes);

      } else {
        debugPrint("🟣 Error: Failed to convert cropped image to byte data.");
      }
    } catch (e, stackTrace) {
      debugPrint("🟣 Error capturing selected area: $e");
      debugPrint("$stackTrace");
    }
  } // End of _captureSelectedArea() 🟣

  void _showAnnotationInputBottomSheet(Uint8List croppedImage) {
    showCustomBottomSheet(
      context: context,
      titleBuilder: (setModalState) => const Text(
        "Annotation 입력",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      contentBuilder: (context) {
        return AnnotationInputForm(
          workRoomId: widget.workRoomId,
          fileName: widget.fileName,
          page: _currentPage,
          selectionRect: _selectionArea,
          image: croppedImage,
          onSave: (text) => _toggleAnnotationMode(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (_fileViewController.isLoading.value ||
          _annotationController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_fileViewController.errorMessage.isNotEmpty ||
          _annotationController.errorMessage.isNotEmpty) {
        return Center(child: Text(_fileViewController.errorMessage.value));
      }
      if (_fileViewController.file.value == null) {
        return const Center(child: Text("File not found."));
      }
      return Stack(
        children: [
          PdfViewerWrapper(
            captureBoundaryKey: captureBoundaryKey,
            pdfViewKey: pdfViewKey,
            filePath: _fileViewController.file.value!.path,
            pdfViewerController: _pdfViewerController,
            pdfTextSearcher: _pdfTextSearcher,
            onViewerReady: (totalPages) {
              setState(() {
                _totalPages = totalPages;
              });
              debugPrint("PDFFileViewScreen: 총 페이지 수 $_totalPages 로드 완료");
            },
            onPageChanged: (page) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
          // 🔶 새로 추가: 현재 페이지에 annotation이 존재하면 좌측 상단에 버튼을 표시
          if (!_isAnnotationMode)
            Positioned(
              top: 142,
              left: 16,
              child: Builder(builder: (context) {
                final annotationsForPage =
                    _annotationController.getAnnotationsForPage(_currentPage);
                if (annotationsForPage.isEmpty) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => _showAnnotationsBottomSheet(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(
                      "+${annotationsForPage.length}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                );
              }),
            ),
          // if (!_isAnnotationMode)
          //   ..._annotationController.annotations
          //       .where((annotation) => annotation.pageNumber == _currentPage)
          //       .map((annotation) {
          //     return Positioned(
          //       left: annotation.area_left,
          //       top: annotation.area_top,
          //       width: annotation.area_width,
          //       height: annotation.area_height,
          //       child: GestureDetector(
          //         onTap: () => _showAnnotationDetails(annotation),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             border: Border.all(color: Colors.blue, width: 2),
          //             color: Colors.blue.withOpacity(0.2),
          //           ),
          //           child: const Icon(Icons.info, color: Colors.white),
          //         ),
          //       ),
          //     );
          //   }).toList(),
          if (_isAnnotationMode)
            AnnotationModeOverlay(
              key: annotationBoundaryKey,
              capturedImage: _capturedImage,
            ),
          if (_isAnnotationMode)
            AnnotationModeControls(
              selectionArea: _selectionArea,
              onUpdate: (newRect) {
                setState(() {
                  _selectionArea = newRect;
                });
              },
              onIconTap: _toggleAnnotationMode,
              onWriteComment: _captureSelectedArea,
            ),
          if (!_isAnnotationMode)
            PdfNavigationControls(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onToggleAnnotationMode: _toggleAnnotationMode,
              pdfViewerController: _pdfViewerController,
              pdfTextSearcher: _pdfTextSearcher,
            ),
        ],
      );
    });
  }



  // 🔶 새로 추가: 현재 페이지의 annotation 목록을 bottom sheet로 표시하는 함수
  void _showAnnotationsBottomSheet() {
    debugPrint('[_showAnnotationsBottomSheet] 호출됨: ' +
        jsonEncode({
          'currentPage': _currentPage,
          'annotationsCount': _annotationController.annotations.length,
        }));

    final pagesWithAnnotations = _annotationController.annotations
        .map((a) => a.pageNumber)
        .where((page) => page != null)
        .map((page) => page!)
        .toSet()
        .toList();
    pagesWithAnnotations.sort();

    int localCurrentPage = _currentPage;

    showCustomBottomSheet(
      context: context,
      titleBuilder: (setModalState) {
        final currentIndex = pagesWithAnnotations.indexOf(localCurrentPage);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            currentIndex > 0
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                localCurrentPage = pagesWithAnnotations[currentIndex - 1];
                setModalState(() {});
              },
            )
                : const SizedBox(width: 48),
            Text(
              'Annotations in Page $localCurrentPage',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            currentIndex < pagesWithAnnotations.length - 1
                ? IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                localCurrentPage = pagesWithAnnotations[currentIndex + 1];
                setModalState(() {});
              },
            )
                : const SizedBox(width: 48),
          ],
        );
      },
      contentBuilder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnnotationListView(
              isInBottomSheet: true,
              annotations: _annotationController.annotations,
              pageNumber: localCurrentPage,
              workRoomWithParticipants: widget.workRoomWithParticipants,
            ),
          ),
        );
      },
    );
  }


// End of PDFFileViewScreen class 🟢
}
