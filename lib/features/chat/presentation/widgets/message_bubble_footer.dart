import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class MessageBubbleFooter extends StatelessWidget {
  final Message message;

  const MessageBubbleFooter({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String time =
        "${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
          child: Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
        if (message.updatedAt.isAfter(message.createdAt))
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 6, right: 2),
            child: Text(
              "수정: ${message.updatedAt.hour.toString().padLeft(2, '0')}:${message.updatedAt.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 10, color: Colors.orange),
            ),
          ),
      ],
    );
  }
}
