import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/thread_controller.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';

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

    // Load threads when the screen opens
    threadController.loadThreads(workRoomId);

    return Column(
      children: [
        // Header
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
            const SizedBox(width: 48), // To balance the close button's space
          ],
        ),
        Expanded(
          child: Obx(() {
            final threads = threadController.threads;

            if (threads.isEmpty) {
              return const Center(child: Text("No threads available."));
            }

            return ListView.builder(
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.threadContent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Emphasize the thread content
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (thread.latestReplyContent != null) // Show the latest reply if available
                        Text(
                          "Latest: ${thread.latestReplyContent}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    "By: ${participantsMap[thread.latestReplySenderId] ?? 'Unknown'} • ${_formatTimestamp(thread.latestReplyUpdatedAt)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // Open thread screen
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height - 40,
                        child: ThreadScreen(
                          parentMessageId: thread.parentMessageId, // Pass the parent message ID
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

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return "Unknown time";
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} • ${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
  }
}
