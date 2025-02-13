import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/users/data/user_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final List<Participant> participantList; // List of participants
  final void Function(Message)? onReply;
  final void Function(Message)? onEdit;

  const MessageTile({
    Key? key,
    required this.message,
    required this.participantList,
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
          // 사용자 정보 가져오기
          final UserModel? user =
          (snapshot.hasData && snapshot.data != null)
              ? snapshot.data![message.senderId]
              : null;

          // 참가자 리스트에서 senderId가 일치하는 참가자 찾기
          final Participant? participant = participantList.firstWhereOrNull(
                  (p) => p.userId == message.senderId);

          // 최종적으로 사용할 사용자명
          final String username = user?.username ??
              participant?.username ??
              "Unknown User";

          // 사용자 이미지 가져오기
          final String? profileImage =
              user?.imageFileStorageKey ?? participant?.imageFileStorageKey;

          return ListTile(
            leading: profileImage != null && profileImage.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
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
