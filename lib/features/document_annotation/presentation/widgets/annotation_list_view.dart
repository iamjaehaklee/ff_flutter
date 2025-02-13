import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import 'package:legalfactfinder2025/app/widgets/custom_bottom_sheet.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/core/utils/image_utils.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/annotation_thread_screen.dart';
import 'package:legalfactfinder2025/features/document_annotation/presentation/widgets/annotation_thread_bottom_sheet.dart';
import 'package:legalfactfinder2025/features/files/presentation/widgets/annotation_sort_option.dart';
import 'package:legalfactfinder2025/features/users/data/user_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart'; // Supabase 이미지 다운로드 함수



class AnnotationListView extends StatefulWidget {
  final List<DocumentAnnotationModel> annotations;
  final bool? isInBottomSheet;
  final int? pageNumber; // 선택적 페이지 번호
  final AnnotationSortOption sortOption;
  final WorkRoomWithParticipants workRoomWithParticipants; // ✅ 추가됨

  const AnnotationListView({
    Key? key,
    required this.annotations,
    this.pageNumber,
    this.isInBottomSheet,
    this.sortOption = AnnotationSortOption.pageArea, // 기본 정렬 옵션
    required this.workRoomWithParticipants, // ✅ 추가됨

  }) : super(key: key);

  @override
  State<AnnotationListView> createState() => _AnnotationListViewState();
}

class _AnnotationListViewState extends State<AnnotationListView> {
  late UsersController usersController ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersController = Get.find<UsersController>();

  }

  @override
  Widget build(BuildContext context) {
    final annotationController = Get.find<AnnotationController>();

    // Annotation 항목 탭 시 호출할 내부 함수

    // pageNumber가 제공되면 해당 페이지의 annotation들만 필터링
    final filteredAnnotations = widget.pageNumber != null
        ? widget.annotations.where((annotation) => annotation.pageNumber == widget.pageNumber).toList()
        : List<DocumentAnnotationModel>.from(widget.annotations);

    // 정렬 옵션에 따라 정렬 수행
    if (widget.sortOption == AnnotationSortOption.pageArea) {
      filteredAnnotations.sort((a, b) {
        // pageNumber가 null이 아니라고 가정
        int cmp = a.pageNumber!.compareTo(b.pageNumber!);
        if (cmp == 0) {
          cmp = a.area_top!.compareTo(b.area_top!);
        }
        return cmp;
      });
    } else if (widget.sortOption == AnnotationSortOption.updatedAt) {
      filteredAnnotations.sort((a, b) {
        // updatedAt이 null이면 createdAt 사용
        final DateTime aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final DateTime bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        // 최신순 정렬 (내림차순)
        return bTime.compareTo(aTime);
      });
    }

    return ListView.separated(
      shrinkWrap: false, // 스크롤이 제대로 작동하도록 shrinkWrap 해제
      itemCount: filteredAnnotations.length,
      separatorBuilder: (context, index) => widget.isInBottomSheet == true
          ? const Divider(height: 8, color: Colors.transparent)
          : const Divider(height: 8, color: Colors.black87, thickness: 8),
      itemBuilder: (context, index) {
        DocumentAnnotationModel annotation = filteredAnnotations[index];
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                showCustomBottomSheet(
                  context: context,
                  titleBuilder: (setModalState) => Text(
                    'Annotation Thread',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  contentBuilder: (context) => ThreadScreen(
                    workRoomId: annotation!.workRoomId!,
                    annotation: annotation,
                    participantList: widget.workRoomWithParticipants.participants,

                  ),
                );
              },
              child: Container(
                decoration: widget.isInBottomSheet == true
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade500, // 윤곽선 색상
                          width: 1.0, // 윤곽선 두께
                        ),
                        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 이미지 영역: 16:9 비율, 이미지가 없으면 진회색 배경
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: annotation.imageFileStorageKey != null
                          ? FutureBuilder<Uint8List?>(
                              future: downloadImageFromSupabase(
                                annotation.imageFileStorageKey!,
                                bucketName: 'work_room_annotations',
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(color: Colors.grey.shade100);
                                }
                                if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white),
                                    ),
                                  );
                                }
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Container(color: Colors.grey.shade800),
                    ),
                    // 하단 정보 영역
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // 작성자 아바타
                            annotation.createdBy.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(annotation.createdBy),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 8),
// 하단 정보 영역의 Expanded 부분을 아래와 같이 수정합니다.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 작성자 이름과 작성일시를 한 줄에 배치
                                  Row(
                                    children: [
                                      FutureBuilder<UserModel?>(
                                        future: usersController.getUserById(annotation.createdBy),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Text(
                                              'Loading...',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            );
                                          }
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return Text(
                                              snapshot.data!.username,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            );
                                          }
                                          return const Text(
                                            'Unknown User',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      Text(
                                        annotation.createdAt != null
                                            ? DateFormat('yyyy-MM-dd HH:mm').format(annotation.createdAt!)
                                            : "",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // 본문 내용
                                  Text(annotation.content ?? "No Content"),
                                  const SizedBox(height: 4),
                                  // 본문 아래에 쓰레드 댓글 수 배치
                                  Row(
                                    children: [
                                      const Icon(Icons.comment, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${annotation.threadCount ?? 0}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 우측 상단에 더보기 메뉴 버튼 추가
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('삭제'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('어노테이션 삭제'),
                        content: const Text('이 어노테이션을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final success = await annotationController
                          .deleteAnnotation(annotation.id!);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('어노테이션이 삭제되었습니다.')),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
