import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';

class ChatScreen extends StatefulWidget {
  final WorkRoom workRoom;
  final String myUserId;
  const ChatScreen({Key? key, required this.workRoom, required this.myUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController _chatController = Get.find<MessageController>();
  final ScrollController _scrollController = ScrollController();
  String? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    // Load messages for the workRoom when the screen initializes
    _chatController.loadMessages(widget.workRoom.id);
  }

  @override
  Widget build(BuildContext context) {
    // Create a map of participants (senderId to username)
    final participantsMap = {
      for (var participant in widget.workRoom.participants)
        participant.userId: participant.username
    };

    return Obx(() {
      if (_chatController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = _chatController.messages;

      return Column(
        children: [
          // Chat messages display
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: MessageBubble(
                    myUserId: widget.myUserId,
                    message: message,
                    participantsMap: participantsMap,
                    isSelected: _selectedMessageId == message.id,
                    onSelected: (selectedMessageId) {
                      setState(() {
                        _selectedMessageId =
                        _selectedMessageId == selectedMessageId ? null : selectedMessageId;

                        if (_selectedMessageId != null) {
                          final selectedIndex = messages.indexWhere((msg) => msg.id == _selectedMessageId);
                          if (selectedIndex != -1) {
                            _scrollToMessage(selectedIndex);
                          }
                        }
                      });
                    },
                    onThread: (threadMessage) {
                      // Show thread for the selected message
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height - 40,
                          child: ThreadScreen(parentMessageId: threadMessage.id, participantsMap: participantsMap, workRoomId: threadMessage.workRoomId,),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Input field for sending messages
          MessageInput(
            workRoomId: widget.workRoom.id,
            onSend: ({
              required String workRoomId,
              required String senderId,
              required String content,
              String? parentMessageId,
              List<File>? attachments,
            }) async {
              if (attachments != null && attachments.isNotEmpty) {
                // Handle attachments logic
                for (final file in attachments) {
                  // Upload logic here
                }
              }
              await _chatController.sendMessage(
                workRoomId: workRoomId,
                senderId: senderId,
                content: content,
              );
            },
          ),

        ],
      );
    });
  }

  void _scrollToMessage(int index) {
    final double position = index * 100.0; // Approximate height of each item
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
