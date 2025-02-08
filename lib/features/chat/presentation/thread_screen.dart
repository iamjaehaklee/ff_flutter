import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/thread_message_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_tile.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';

class ThreadScreen extends StatefulWidget {
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
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ThreadMessageController threadMessageController = Get.find<ThreadMessageController>();
  final MessageController messageController = Get.find<MessageController>();

  Message? _editingMessage;
  Message? _replyingToMessage;

  late Future<Message> _parentMessageFuture;
  String? _topLevelMessageId;

  /// 재귀적으로 최상위 부모 메시지를 가져오는 함수
  Future<Message> _getTopLevelMessage(String messageId) async {
    Message message = await messageController.getMessageById(messageId);
    // parentMessageId가 null이면 최상위 메시지임
    while (message.parentMessageId != null) {
      message = await messageController.getMessageById(message.parentMessageId!);
    }
    return message;
  }

  @override
  void initState() {
    super.initState();
    // 최상위 부모 메시지를 Future로 로드
    _parentMessageFuture = _getTopLevelMessage(widget.parentMessageId);
    // 최상위 메시지를 로드한 후 쓰레드 메시지도 로드
    _parentMessageFuture.then((topLevelMessage) {
      _topLevelMessageId = topLevelMessage.id;
      threadMessageController.loadThreadMessages(topLevelMessage.id);
    });
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
        // 부모 메시지 헤더 영역 (MessageTile으로 표시하며, 상단에 '부모 메시지' 레이블을 붙임)
        FutureBuilder<Message>(
          future: _parentMessageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Error loading parent message"),
              );
            }
            if (!snapshot.hasData) {
              return const SizedBox();
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
                      participantsMap: widget.participantsMap,
                      // 부모 메시지는 답장이나 편집 기능이 없으므로 null로 처리
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
                  participantsMap: widget.participantsMap,
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
        // ... ThreadScreen 의 나머지 코드는 동일합니다.
        MessageInput(
          workRoomId: widget.workRoomId,
          parentMessageId: _topLevelMessageId ?? widget.parentMessageId,
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
              // 새 쓰레드 메시지 전송
              await threadMessageController.sendThreadMessage(
                workRoomId: workRoomId,
                senderId: senderId,
                content: content,
                parentMessageId: parentMessageId!,
              );
              // 부모 메시지의 threadCount 업데이트 (이전 업데이트 코드가 있다면 함께 유지)
              final parentId = parentMessageId;
              final parentIndex = messageController.messages.indexWhere((msg) => msg.id == parentId);
              if (parentIndex != -1) {
                final parentMsg = messageController.messages[parentIndex];
                messageController.messages[parentIndex] = parentMsg.copyWith(
                  threadCount: (parentMsg.threadCount ?? 0) + 1,
                );
              }
              // ChatScreen에도 새 쓰레드 메시지가 반영되도록 전체 메시지 목록을 재로딩
              await messageController.loadMessages(workRoomId);
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
