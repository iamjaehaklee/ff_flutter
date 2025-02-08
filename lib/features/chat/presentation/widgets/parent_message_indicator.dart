import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class ParentMessageIndicator extends StatelessWidget {
  final Color? backgroundColor;
  final Message message;
  final void Function(String)? onShowParentMessage;

  const ParentMessageIndicator({
    Key? key,
    required this.backgroundColor,
    required this.message,
    this.onShowParentMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("[ParentMessageIndicator] Building indicator for message id: ${message.parentMessageId}");
    return GestureDetector(
      onTap: () {
        print("[ParentMessageIndicator] Tapped indicator for message id: ${message.parentMessageId}");
        if (message.parentMessageId != null) {
          onShowParentMessage?.call(message.parentMessageId!);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Parent message",
          style: TextStyle(fontSize: 12, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
