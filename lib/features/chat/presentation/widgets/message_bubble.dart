import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.senderId == myUserId;
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isSelected
        ? (isCurrentUser ? Colors.blue.shade300 : Colors.grey.shade400)
        : (isCurrentUser ? Colors.blue : Colors.grey[300]);
    final textColor = isCurrentUser ? Colors.white : Colors.black;
    final username = participantsMap[message.senderId] ?? "Unknown";
    final time =
        "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";
    bool isImage = message.attachmentFileType?.startsWith('image') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        if (isImage)
          Image.network(message.attachmentFileStorageKey!, width: 200, height: 200, fit: BoxFit.cover)
        else
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    "https://via.placeholder.com/150",
                  ),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            Column(
              crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => _showBottomSheet(context),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(color: textColor),
                          softWrap: true,
                        ),
                        if (message.threadCount > 0) // Display thread count if greater than 0
                          GestureDetector(
                            onTap: () => _showThreadBottomSheet(context), // Open thread screen
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Thread: ${message.threadCount}",
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white70 : Colors.blueAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.comment,
                label: "Thread",
                onTap: () {
                  Navigator.pop(context);
                  _showThreadBottomSheet(context);
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.reply,
                label: "Reply",
                onTap: () {
                  Navigator.pop(context);
                  if (onReply != null) onReply!(message);
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.edit,
                label: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  if (onEdit != null) onEdit!(message);
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.delete,
                label: "Delete",
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!(message);
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.star,
                label: "Mark Important",
                onTap: () {
                  Navigator.pop(context);
                  if (onMarkImportant != null) onMarkImportant!(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThreadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height - 40,
          child: ThreadScreen(
            parentMessageId: message.id,
            workRoomId: message.workRoomId,
            participantsMap: participantsMap,
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
