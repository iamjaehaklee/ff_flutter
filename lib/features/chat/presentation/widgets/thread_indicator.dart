import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class ThreadIndicator extends StatelessWidget {
  final Message message;
  final Color color;
  final void Function(Message)? onThread;

  const ThreadIndicator({
    Key? key,
    required this.message,
    required this.color,
    this.onThread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("[ThreadIndicator] Building thread indicator for message id: ${message.id}");
    return GestureDetector(
      onTap: () {
        print("[ThreadIndicator] Tapped thread indicator for message id: ${message.id}");
        onThread?.call(message);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              "${message.threadCount} replies",
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
