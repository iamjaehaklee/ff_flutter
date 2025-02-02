import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/thread_message_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_tile.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';

class ThreadScreen extends StatelessWidget {
  final String parentMessageId;
  final String workRoomId;
  final Map<String, String> participantsMap;

  const ThreadScreen({
    Key? key,
    required this.parentMessageId,
    required this.workRoomId,
    required this.participantsMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThreadMessageController threadMessageController = Get.find<ThreadMessageController>();

    // Load thread messages and parent message when the screen opens
    threadMessageController.loadThreadMessages(parentMessageId);

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
              "Thread",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(),
        // Parent message display
        Obx(() {
          final parentMessage = threadMessageController.parentMessage.value;

          if (threadMessageController.isLoading.value && parentMessage == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (parentMessage == null) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Failed to load parent message."),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MessageTile(
                message: parentMessage,
                participantsMap: participantsMap,
              ),
              const Divider(),
            ],
          );
        }),
        // Thread messages display
        Expanded(
          child: Obx(() {
            final threadMessages = threadMessageController.threadMessages;

            if (threadMessageController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (threadMessages.isEmpty) {
              return const Center(child: Text("No replies yet."));
            }

            return ListView.builder(
              itemCount: threadMessages.length,
              itemBuilder: (context, index) {
                final message = threadMessages[index];
                return MessageTile(
                  message: message,
                  participantsMap: participantsMap,
                );
              },
            );
          }),
        ),
        // Input field to reply to thread
        MessageInput(
          workRoomId: workRoomId,
          parentMessageId: parentMessageId,
          onSend: ({
            required String workRoomId,
            required String senderId,
            required String content,
            String? parentMessageId,
            List<File>? attachments,
          }) async {
            if (attachments != null && attachments.isNotEmpty) {
              // Handle attachments logic for threads
              for (final file in attachments) {
                // Upload logic here
              }
            }
            await threadMessageController.sendThreadMessage(
              workRoomId: workRoomId,
              senderId: senderId,
              content: content,
              parentMessageId: parentMessageId!,
            );
          },
        ),

      ],
    );
  }
}
