import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_annotation_threads_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_info_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_view_layout.dart';
import 'package:legalfactfinder2025/features/files/presentation/pdf_file_view_screen.dart';

class FilePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    content: SelectableText(fileName),
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
              fileName,
              overflow: TextOverflow.ellipsis, // 긴 파일명을 줄여서 표시
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicator: const BoxDecoration(),
              indicatorColor: Colors.transparent,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.file_present, size: ICON_SIZE_AT_APPBAR)),
                Tab(icon: Icon(Icons.comment, size: ICON_SIZE_AT_APPBAR)),
                Tab(icon: Icon(Icons.info, size: ICON_SIZE_AT_APPBAR)),

              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            FileViewLayout(
              workRoomId: workRoomId,
              fileName: fileName,
            ),
            FileAnnotationThreadsScreen(
              workRoomId: workRoomId,
              fileName: fileName,
              parentFileStorageKey: storageKey,
            ),
            FileInfoScreen()
          ],
        ),
      ),
    );
  }
}
