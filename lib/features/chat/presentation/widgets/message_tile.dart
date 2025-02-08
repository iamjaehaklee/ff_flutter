import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/users/data/user_model.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final Map<String, String> participantsMap; // Map of senderId to username
  final void Function(Message)? onReply;
  final void Function(Message)? onEdit;

  const MessageTile({
    Key? key,
    required this.message,
    required this.participantsMap,
    this.onReply,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usersController = Get.find<UsersController>();

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: FutureBuilder<Map<String, UserModel>>(
        future: usersController.getUsersByIds([message.senderId]),
        builder: (context, snapshot) {
          final UserModel? user =
              snapshot.hasData ? snapshot.data![message.senderId] : null;
          final username = user?.username ??
              participantsMap[message.senderId] ??
              "Unknown User";

          return ListTile(
            leading: user?.imageFileStorageKey != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.imageFileStorageKey!),
                  )
                : CircleAvatar(
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
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} • ${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
  }

  /// ✅ **Handles message actions**
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text("Reply"),
              onTap: () {
                Navigator.pop(context);
                if (onReply != null) onReply!(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) onEdit!(message);
              },
            ),
          ],
        );
      },
    );
  }
}
