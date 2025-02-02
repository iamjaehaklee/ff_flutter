import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/annotation_repository.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/annotation_thread_screen.dart';

class FileAnnotationThreadsScreen extends StatefulWidget {
  final String workRoomId;
  final String fileName;
  final String parentFileStorageKey;

  const FileAnnotationThreadsScreen({
    Key? key,
    required this.workRoomId,
    required this.fileName,
    required this.parentFileStorageKey,
  }) : super(key: key);

  @override
  _FileAnnotationThreadsScreenState createState() =>
      _FileAnnotationThreadsScreenState();
}

class _FileAnnotationThreadsScreenState
    extends State<FileAnnotationThreadsScreen> with AutomaticKeepAliveClientMixin {
  final AnnotationController controller = Get.put(AnnotationController());
  final AnnotationRepository repository = AnnotationRepository();

  @override
  void initState() {
    super.initState();
    controller.fetchAnnotations(widget.parentFileStorageKey);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    controller.fetchAnnotations(widget.parentFileStorageKey),
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }

      if (controller.annotations.isEmpty) {
        return const Center(child: Text("No annotations found."));
      }

      return ListView.separated(
        itemCount: controller.annotations.length,
        separatorBuilder: (context, index) => const Divider(height: 40, ),
        itemBuilder: (context, index) {
          final annotation = controller.annotations[index];

          // Extract details
          final imageStorageKey = annotation['image_file_storage_key'];
          final content = annotation['content'] ?? 'No Content';
          final username = annotation['username'] ?? 'Unknown User';
          final avatarUrl = annotation['avatar_url'];

          return GestureDetector(
            onTap: () {
              _showAnnotationThreadBottomSheet(context, annotation);
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageStorageKey != null)
                    FutureBuilder<String>(
                      future: repository.getPublicUrl(imageStorageKey),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Error loading image: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        if (snapshot.hasData) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit.contain, // Ensures the full image is visible without clipping
                              width: double.infinity, // Takes up the full width of the container
                            ),
                          );
                        }
                        return const Text("No image available.");
                      },
                    ),
                  ListTile(
                    leading: avatarUrl != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                    )
                        : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(username),
                    subtitle: Text(content),
                  ),
                  // Text(JsonEncoder.withIndent('  ').convert(annotation))
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// Show the Bottom Sheet with annotation threads
  void _showAnnotationThreadBottomSheet(
      BuildContext context, Map<String, dynamic> annotationData) {
    final annotation = DocumentAnnotationModel.fromJson(annotationData); // Convert map to model

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // 90% of the screen
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return AnnotationThreadScreen(
              annotation: annotation,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}
