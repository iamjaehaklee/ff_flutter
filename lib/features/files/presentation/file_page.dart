import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_loading_error.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_view_layout.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_annotation_threads_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_info_screen.dart';

class FilePage extends StatefulWidget {
  final String workRoomId;
  final String fileName;
  final String storageKey;

  const FilePage({
    Key? key,
    required this.workRoomId,
    required this.fileName,
    required this.storageKey,
  }) : super(key: key);

  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  late WorkRoomController workRoomController;
  Future<WorkRoomWithParticipants?>? workRoomFuture;

  @override
  void initState() {
    super.initState();
    workRoomController = Get.find<WorkRoomController>();

    // ✅ `FutureBuilder`에서 처리하도록 비동기 데이터 로딩
    workRoomFuture =
        workRoomController.fetchWorkRoomWithParticipantsByWorkRoomId(widget.workRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkRoomWithParticipants?>(
      future: workRoomFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return WorkRoomLoadingError(
            isLoading: false,
            errorMessage: 'Failed to load work room: ${snapshot.error}',
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const WorkRoomLoadingError(
            isLoading: false,
            errorMessage: 'Work room not found.',
          );
        }

        final workRoomWithParticipants = snapshot.data!;

        return GetBuilder<WorkRoomController>(
          builder: (controller) {
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("File Name"),
                            content: SelectableText(widget.fileName),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.fileName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  bottom: const TabBar(
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.file_present, size: 24)),
                      Tab(icon: Icon(Icons.comment, size: 24)),
                      Tab(icon: Icon(Icons.info, size: 24)),
                    ],
                  ),
                ),
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    FileViewLayout(
                      workRoomId: widget.workRoomId,
                      fileName: widget.fileName,
                      storageKey: widget.storageKey,
                      workRoomWithParticipants: workRoomWithParticipants,
                    ),
                    FileAnnotationThreadsScreen(
                      workRoomId: widget.workRoomId,
                      fileName: widget.fileName,
                      parentFileStorageKey: widget.storageKey,
                      workRoomWithParticipants: workRoomWithParticipants,
                    ),
                    FileInfoScreen(
                      storageKey: widget.storageKey,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
