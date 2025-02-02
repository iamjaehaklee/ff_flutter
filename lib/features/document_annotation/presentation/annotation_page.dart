import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';

class AddAnnotationPage extends StatefulWidget {
  final List<Rect> selectedParagraphs;
  final Uint8List pdfImage;

  AddAnnotationPage({required this.selectedParagraphs, required this.pdfImage});

  @override
  _AddAnnotationPageState createState() => _AddAnnotationPageState();
}

class _AddAnnotationPageState extends State<AddAnnotationPage> {
  TextEditingController _contentController = TextEditingController();

  void _saveAnnotation() async {
    // await AnnotationController.saveAnnotation(
    //   paragraphs: widget.selectedParagraphs,
    //   content: _contentController.text,
    // );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Annotation")),
      body: Column(
        children: [
          Expanded(
            child: Image.memory(widget.pdfImage),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: "내용 입력",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("취소")),
              ElevatedButton(onPressed: _saveAnnotation, child: Text("확인")),
            ],
          ),
        ],
      ),
    );
  }
}
