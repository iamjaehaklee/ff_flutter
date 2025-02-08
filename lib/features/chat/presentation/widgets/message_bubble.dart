import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble_content.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble_footer.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble_avatar.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble_actions.dart';

class MessageBubble extends StatelessWidget {
  final String myUserId;
  final Message message;
  final Map<String, String> participantsMap;
  final bool isSelected;
  final void Function(String)? onSelected;
  final void Function(Message)? onThread;
  final void Function(Message)? onReply;
  final void Function(Message)? onEdit;
  final void Function(Message)? onDelete;
  final void Function(Message)? onMarkImportant;
  // 부모 메시지 표시 요청 콜백
  final void Function(String)? onShowParentMessage;

  const MessageBubble({
    Key? key,
    required this.myUserId,
    required this.message,
    required this.participantsMap,
    required this.isSelected,
    this.onSelected,
    this.onThread,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onMarkImportant,
    this.onShowParentMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.senderId == myUserId;

    return Column(
      crossAxisAlignment:
      isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              MessageBubbleAvatar(
                  username: participantsMap[message.senderId] ?? "Unknown"),
            Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      participantsMap[message.senderId] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                // onShowParentMessage 콜백을 MessageBubbleContent에 전달
                MessageBubbleContent(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  onTap: () => showMessageOptions(
                    context,
                    message,
                    onThread,
                    onReply,
                    onEdit,
                    onDelete,
                    onMarkImportant,
                  ),
                  onThread: onThread,
                  onShowParentMessage: onShowParentMessage,
                ),
                MessageBubbleFooter(message: message), // Timestamp only
              ],
            ),
          ],
        ),
      ],
    );
  }
}
