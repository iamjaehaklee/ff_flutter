import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';

import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

Widget buildThreadLink(BuildContext context, Message message, Map<String, String> participantsMap, String myUserId) {
  if (message.threadCount == 0) return SizedBox.shrink(); // ✅ Hide if no thread

  final bool isCurrentUser = message.senderId == myUserId;
  final Color iconColor = isCurrentUser ? Colors.white : Colors.blueAccent;

  return GestureDetector(
    onTap: () => _showThreadBottomSheet(context, message, participantsMap),
    child: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.comment, size: 14, color: iconColor), // ✅ Small comment icon
          const SizedBox(width: 4),
          Text(
            message.threadCount.toString(),
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}


void _showThreadBottomSheet(BuildContext context, Message message, Map<String, String> participantsMap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height - 60,
        child: ThreadScreen(
          parentMessageId: message.id,
          workRoomId: message.workRoomId,
          participantsMap: participantsMap,
        ),
      );
    },
  );
}
