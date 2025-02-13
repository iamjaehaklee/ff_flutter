import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';
import 'package:legalfactfinder2025/features/chat/thread_message_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';

import 'widgets/message_tile.dart';

class ThreadScreen extends StatefulWidget {
  final String workRoomId;
  final List<Participant> participantList;
  final DocumentAnnotationModel? annotation;

  const ThreadScreen({
    Key? key,
    required this.workRoomId,
    required this.participantList,
    this.annotation,
  }) : super(key: key);

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ThreadMessageController threadMessageController = Get.find<ThreadMessageController>();
  final MessageController messageController = Get.find<MessageController>();

  Message? _editingMessage;
  Message? _replyingToMessage;

  late Future<Message?> _parentMessageFuture;
  String? _topLevelMessageId;

  @override
  void initState() {
    super.initState();

    String? parentMessageId = widget.annotation?.chatMessageId;

    if (parentMessageId == null) {
      _parentMessageFuture = Future.value(null);
    } else {
      _parentMessageFuture = _getTopLevelMessage(parentMessageId);
    }

    _parentMessageFuture.then((topLevelMessage) {
      if (topLevelMessage != null) {
        _topLevelMessageId = topLevelMessage.id;
        threadMessageController.loadParentMessageAndThreadMessageList(topLevelMessage.id);
      }
    });
  }

  Future<Message?> _getTopLevelMessage(String messageId) async {
    try {
      Message? message = await messageController.getMessageById(messageId);
      if (message == null) return null;

      while (message!.parentMessageId != null) {
        message = await messageController.getMessageById(message.parentMessageId!);
        if (message == null) break;
      }
      return message;
    } catch (e) {
      debugPrint("Error fetching top-level message: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 타이틀 영역
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
        // 부모 메시지 헤더 영역
        FutureBuilder<Message?>(
          future: _parentMessageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Error loading parent message"),
              );
            }
            final parentMessage = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "부모 메시지",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MessageTile(
                      message: parentMessage,
                      participantList: widget.participantList,
                      onReply: null,
                      onEdit: null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // 답글 목록 영역
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
                  participantList: widget.participantList,
                  onReply: (replyMessage) {
                    setState(() {
                      _replyingToMessage = replyMessage;
                    });
                  },
                  onEdit: (editMessage) {
                    setState(() {
                      _editingMessage = editMessage;
                    });
                  },
                );
              },
            );
          }),
        ),
        // 메시지 입력 영역
        MessageInput(
          workRoomId: widget.workRoomId,
          parentMessageId: _topLevelMessageId,
          editingMessage: _editingMessage,
          replyingToMessage: _replyingToMessage,
          onSend: ({
            required String workRoomId,
            required String senderId,
            required String content,
            String? parentMessageId,
            String? editingMessageId,
            List<File>? attachments,
          }) async {
            if (editingMessageId != null) {
              await threadMessageController.editThreadMessage(editingMessageId, content);
            } else {
              await threadMessageController.sendThreadMessage(
                workRoomId: workRoomId,
                senderId: senderId,
                content: content,
                parentMessageId: parentMessageId!,
              );
              await messageController.loadMessagesByWorkRoomId(workRoomId);
            }
          },
          onCancelEditingOrReplying: () {
            setState(() {
              _editingMessage = null;
              _replyingToMessage = null;
            });
          },
        ),
      ],
    );
  }
}
