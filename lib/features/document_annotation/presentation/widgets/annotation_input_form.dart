import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/ocr/services/ocr_kr_naver_clova_service.dart';

class AnnotationInputForm extends StatefulWidget {
  final Function(String) onSave;
  final Uint8List? image;
  final String workRoomId;
  final String fileName;
  final int page;
  final Rect selectionRect;

  const AnnotationInputForm({
    Key? key,
    required this.onSave,
    this.image,
    required this.workRoomId,
    required this.fileName,
    required this.page,
    required this.selectionRect,
  }) : super(key: key);

  @override
  _AnnotationInputFormState createState() => _AnnotationInputFormState();
}

class _AnnotationInputFormState extends State<AnnotationInputForm> {
  String ocrText = "";
  String annotationText = "";
  bool isOcrLoading = false;
  bool isOcrPerformed = false; // OCR 실행 여부
  final ScrollController _scrollController = ScrollController();
  final FocusNode _annotationFocusNode = FocusNode();
  /// OCR 요청 함수
  Future<void> _performOcr(StateSetter setModalState) async {
    if (widget.image == null) return;

    setModalState(() {
      isOcrLoading = true;
    });

    final ocrResult = await OcrKrNaverClovaService.performOcr(widget.image!);

    setModalState(() {
      isOcrLoading = false;
      isOcrPerformed = true; // OCR 실행 완료
      ocrText = ocrResult?.trim() ?? "OCR 인식 실패"; // ✅ 불필요한 공백 제거
    });
  }
  @override
  void initState() {
    super.initState();

    // 🔹 키보드가 올라오면 자동 스크롤
    _annotationFocusNode.addListener(() {
      if (_annotationFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }
  /// 🔹 스크롤을 끝까지 내리는 함수
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _annotationFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          controller: _scrollController, // 🔹 스크롤 컨트롤러 추가

          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 0,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.black12,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 🔹 캡처된 이미지 표시 (빨간 테두리 추가)
                        if (widget.image != null)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: Image.memory(widget.image!, height: 150),
                          ),
                        const SizedBox(height: 16),

                        // 🔹 OCR 실행 버튼 (한번 실행 후 "OCR 재시도"로 변경)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("OCR 결과",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            if (widget.image != null)
                              TextButton.icon(
                                onPressed: () => _performOcr(setModalState),
                                icon: isOcrLoading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2)
                                    : const Icon(Icons.text_snippet),
                                label:
                                    Text(isOcrPerformed ? "OCR 재시도" : "OCR 실행"),
                              ),
                          ],
                        ),

                        // 🔹 OCR 결과 텍스트 표시 (읽기 전용)
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          minLines: 3,
                          maxLines: 5,
                          controller: TextEditingController(text: ocrText),
                          readOnly: true,
                        ),


                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // 🔹 사용자가 입력하는 Annotation 텍스트 필드
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: const Text("Annotation 입력",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "추가할 주석을 입력하세요.",
                  ),
                  minLines: 3,
                  maxLines: 5,
                  focusNode: _annotationFocusNode, // 🔹 키보드 감지를 위한 FocusNode 추가

                  onChanged: (value) {
                    setModalState(() {
                      annotationText = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 🔹 버튼들 (취소, 저장)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (annotationText.isNotEmpty) {
                            final AnnotationController controller =
                                Get.find<AnnotationController>();
                            bool success = await controller.saveAnnotation(
                              workRoomId: widget.workRoomId,
                              fileName: widget.fileName,
                              page: widget.page,
                              rect: widget.selectionRect,
                              text: annotationText,
                              imageBytes: widget.image,
                            );
                            if (success) {
                              widget.onSave(annotationText);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
