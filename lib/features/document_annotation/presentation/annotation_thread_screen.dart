import 'package:flutter/material.dart';

import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';

class AnnotationThreadScreen extends StatelessWidget {
  final DocumentAnnotationModel annotation;
  final ScrollController scrollController;

  const AnnotationThreadScreen({
    Key? key,
    required this.annotation,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Text(
              "Annotation Thread",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(),
        // Parent annotation display
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            annotation.content ?? 'No Content',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const Divider(),
        // Placeholder for thread messages
        Expanded(
          child: Center(
            child: Text(
              "Thread messages will be displayed here.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),
        // Placeholder for input field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Add a reply...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
