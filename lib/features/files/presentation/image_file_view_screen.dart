import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/annotation_repository.dart';
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class ImageFileViewScreen extends StatefulWidget {
  final String workRoomId;
  final String fileName;

  const ImageFileViewScreen({
    Key? key,
    required this.workRoomId,
    required this.fileName,
  }) : super(key: key);

  @override
  _ImageFileViewScreenState createState() => _ImageFileViewScreenState();
}

class _ImageFileViewScreenState extends State<ImageFileViewScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey _imageViewKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  bool _isAnnotationMode = false;
  Rect? _selectedRect;
  ui.Image? _croppedImage;

   final AnnotationController _annotationController = Get.put(AnnotationController());

  @override
  void initState() {
    super.initState();
    final FileViewController controller = Get.find<FileViewController>();
    controller.loadFile(
      'work_room_files',
      '${widget.workRoomId}/${widget.fileName}',
      widget.fileName,
    );
  }

  void _startDrawing(Offset startPosition) {
    setState(() {
      _selectedRect = Rect.fromLTWH(startPosition.dx, startPosition.dy, 0, 0);
    });
  }

  void _updateDrawing(Offset currentPosition) {
    setState(() {
      if (_selectedRect != null) {
        _selectedRect = Rect.fromLTRB(
          _selectedRect!.left < currentPosition.dx
              ? _selectedRect!.left
              : currentPosition.dx,
          _selectedRect!.top < currentPosition.dy
              ? _selectedRect!.top
              : currentPosition.dy,
          _selectedRect!.right > currentPosition.dx
              ? _selectedRect!.right
              : currentPosition.dx,
          _selectedRect!.bottom > currentPosition.dy
              ? _selectedRect!.bottom
              : currentPosition.dy,
        );
      }
    });
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    String annotationText = "";

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
              TextField(
                decoration: const InputDecoration(
                  labelText: "Enter annotation",
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 8,
                onChanged: (value) {
                  annotationText = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (annotationText.isNotEmpty && _selectedRect != null) {
                    bool success = await _annotationController.saveAnnotation(
                      workRoomId: widget.workRoomId,
                      fileName: widget.fileName,
                      page: 0,
                      rect: _selectedRect!,
                      text: annotationText,
                      imageBytes: null,
                    );

                    if (success) {
                      Navigator.pop(context);
                      setState(() {
                        _selectedRect = null;
                      });
                    } else {
                      print("Failed to save annotation");
                    }
                  }
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 16),
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
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      }

      if (controller.file.value == null) {
        return const Center(child: Text("File not found."));
      }

      final file = controller.file.value!;
      return Stack(
        children: [
          GestureDetector(
            onPanStart: _isAnnotationMode
                ? (details) => _startDrawing(details.localPosition)
                : null,
            onPanUpdate: _isAnnotationMode
                ? (details) => _updateDrawing(details.localPosition)
                : null,
            onTapUp: _isAnnotationMode
                ? (details) async => await _showBottomSheet(context)
                : null,
            child: Image.file(
              file,
              key: _imageViewKey,
              fit: BoxFit.contain,
            ),
          ),
          if (_selectedRect != null)
            Positioned.fromRect(
              rect: _selectedRect!,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () =>
                  setState(() => _isAnnotationMode = !_isAnnotationMode),
              backgroundColor: Colors.blue,
              child: Icon(_isAnnotationMode ? Icons.close : Icons.comment,
                  color: Colors.white),
            ),
          ),
        ],
      );
    });
  }
}
