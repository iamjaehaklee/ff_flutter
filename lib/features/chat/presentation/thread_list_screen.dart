import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/thread_controller.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_tile_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';

class ThreadListScreen extends StatelessWidget {
  final String workRoomId;
  final List<Participant> participantList;

  const ThreadListScreen({
    Key? key,
    required this.workRoomId,
    required this.participantList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThreadTileListController threadController =
        Get.find<ThreadTileListController>();

    threadController.loadThreadTileList(workRoomId);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "Threads",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 48),
          ],
        ),
        Expanded(
          child: Obx(() {
            if (threadController.isThreadTileListLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final threads = threadController.threadTileList;

            if (threads.isEmpty) {
              return const Center(child: Text("No threads available."));
            }

            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final threadTileModel = threads[index];
                final parent = threadTileModel.parent;
                final child = threadTileModel.child;

                // 🔹 `participantList`에서 senderId에 해당하는 참가자 찾기
                final parentParticipant = participantList
                    .firstWhereOrNull((p) => p.userId == parent.senderId);
                final childParticipant = child != null
                    ? participantList
                        .firstWhereOrNull((p) => p.userId == child.senderId)
                    : null;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text(
                      parentParticipant?.username[0] ?? 'U',
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        "${parentParticipant?.username ?? 'Unknown'}: ",
                        style: const TextStyle(fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          parent.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (child != null && child.content.isNotEmpty)
                        Row(
                          children: [
                            const Text(
                              "최근: ",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            CircleAvatar(
                              radius: 8,
                              child: Text(
                                childParticipant?.username[0] ?? 'U',
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${childParticipant?.username ?? 'Unknown'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(child.createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      Text(
                        "${parent.threadCount} replies",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height - 40,
                        child: ThreadScreen(
                          workRoomId: workRoomId,
                          participantList: participantList,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
