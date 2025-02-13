// File: lib/screens/file_annotation_threads_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/annotation_thread_screen.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_list_view.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_thread_bottom_sheet.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_sort_option.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';


class FileAnnotationThreadsScreen extends StatefulWidget {
  final String workRoomId;
  final String fileName;
  final String parentFileStorageKey;
  final WorkRoomWithParticipants workRoomWithParticipants;

  const FileAnnotationThreadsScreen({
    Key? key,
    required this.workRoomId,
    required this.fileName,
    required this.parentFileStorageKey,
    required this.workRoomWithParticipants,

  }) : super(key: key);

  @override
  _FileAnnotationThreadsScreenState createState() =>
      _FileAnnotationThreadsScreenState();
}
// 추가: Annotation 정렬 옵션 상태 변수 (기본은 문서 위치순)
AnnotationSortOption _annotationSortOption = AnnotationSortOption.pageArea;


class _FileAnnotationThreadsScreenState
    extends State<FileAnnotationThreadsScreen>
    with AutomaticKeepAliveClientMixin {
  final AnnotationController annotationController =
  Get.put(AnnotationController());

  @override
  void initState() {
    super.initState();
    // 상세 파라미터 로그
    debugPrint(
        '[FileAnnotationThreadsScreen.initState] workRoomId: ${widget
            .workRoomId}');
    debugPrint(
        '[FileAnnotationThreadsScreen.initState] fileName: ${widget.fileName}');
    debugPrint(
        '[FileAnnotationThreadsScreen.initState] parentFileStorageKey: ${widget
            .parentFileStorageKey}');
    // 🔶 수정: 첫 프레임 이후에 fetchAnnotationsByParentFileStorageKey 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      annotationController
          .fetchAnnotationsByParentFileStorageKey(widget.parentFileStorageKey);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Obx(() {
      if (annotationController.isLoading.value) {
        debugPrint('[FileAnnotationThreadsScreen.build] isLoading true');
        return const Center(child: CircularProgressIndicator());
      }

      if (annotationController.errorMessage.isNotEmpty) {
        debugPrint(
            '[FileAnnotationThreadsScreen.build] errorMessage: ${annotationController
                .errorMessage.value}');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(annotationController.errorMessage.value,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  debugPrint(
                      '[FileAnnotationThreadsScreen.build] Retry button pressed. Fetching annotations for parentFileStorageKey: ${widget
                          .parentFileStorageKey}');
                  annotationController.fetchAnnotationsByParentFileStorageKey(
                      widget.parentFileStorageKey);
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }

      if (annotationController.annotations.isEmpty) {
        debugPrint('[FileAnnotationThreadsScreen.build] No annotations found.');
        return const Center(child: Text("No annotations found."));
      }

      // 🔶 AnnotationListView 위젯을 사용하여 annotation 목록을 재사용
      return Stack(
        children: [
          Container(
            color: Colors.black38,
          ),
          AnnotationListView(
              annotations: annotationController.annotations,
              sortOption: _annotationSortOption,
              workRoomWithParticipants: widget.workRoomWithParticipants,
          ),
          // 새로 추가: 왼쪽 상단 고정 필터 아이콘
          Positioned(
            top: 16,
            left: 16,
            child: PopupMenuButton<AnnotationSortOption>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              itemBuilder: (context) =>
              [
                PopupMenuItem(
                  value: AnnotationSortOption.pageArea,
                  child: const Text('문서 위치순'),
                ),
                PopupMenuItem(
                  value: AnnotationSortOption.updatedAt,
                  child: const Text('최신 업데이트 순'),
                ),
              ],
              onSelected: (option) {
                setState(() {
                  _annotationSortOption = option;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.filter_list, color: Colors.black),
              ),
            ),
          ),
        ],
      );
    });
  }
}
