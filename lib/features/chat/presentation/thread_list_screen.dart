import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/thread_controller.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_model.dart';

class ThreadListScreen extends StatelessWidget {
  final String workRoomId;
  final Map<String, String> participantsMap;

  const ThreadListScreen({
    Key? key,
    required this.workRoomId,
    required this.participantsMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThreadController threadController = Get.find<ThreadController>();

    threadController.loadThreads(workRoomId);

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
            if (threadController.isThreadsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final threads = threadController.threads;

            if (threads.isEmpty) {
              return const Center(child: Text("No threads available."));
            }

            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                final parent = thread.parentMessage;
                final child = thread.childMessage;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text(
                      participantsMap[parent.senderId]?[0] ?? 'U',
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        "${participantsMap[parent.senderId] ?? 'Unknown'}: ",
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
                      if (child.content.isNotEmpty)
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
                                participantsMap[child.senderId]?[0] ?? 'U',
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${participantsMap[child.senderId] ?? 'Unknown'}",
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
                          parentMessageId: parent.id,
                          workRoomId: workRoomId,
                          participantsMap: participantsMap,
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
