import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final Map<String, String> participantsMap; // Map of senderId to username

  const MessageTile({
    Key? key,
    required this.message,
    required this.participantsMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the sender's username from the participants map
    final username = participantsMap[message.senderId] ?? "Unknown User";

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : "?",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        username,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(message.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    // Format the timestamp into a readable format
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} • ${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
  }
}
