import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';

class MessageHighlightIcon extends StatelessWidget {
  final String? highlight;
  final String messageId;

  const MessageHighlightIcon({
    Key? key,
    required this.highlight,
    required this.messageId,
  }) : super(key: key);

  static final Map<String, Widget> highlightIcons = {
    'important': _buildHighlightContainer(
      color: const Color(0xFFFFF3E0),
      borderColor: Colors.orange,
      icon: const Icon(
        Icons.priority_high_rounded,
        size: 14,
        color: Colors.orange,
      ),
    ),
    'warning': _buildHighlightContainer(
      color: const Color(0xFFFFEBEE),
      borderColor: Colors.red,
      icon: const Icon(
        Icons.warning_rounded,
        size: 14,
        color: Colors.red,
      ),
    ),
    'thumb': _buildHighlightContainer(
      color: const Color(0xFFE3F2FD),
      borderColor: Colors.blue,
      icon: const Icon(
        Icons.thumb_up_rounded,
        size: 14,
        color: Colors.blue,
      ),
    ),
    'smile': _buildHighlightContainer(
      color: const Color(0xFFF1F8E9),
      borderColor: Colors.green,
      icon: const Icon(
        Icons.mood_rounded,
        size: 14,
        color: Colors.green,
      ),
    ),
    'check': _buildHighlightContainer(
      color: const Color(0xFFE8F5E9),
      borderColor: Colors.green,
      icon: const Icon(
        Icons.task_alt_rounded,
        size: 14,
        color: Colors.green,
      ),
    ),
  };

  static Widget _buildHighlightContainer({
    required Color color,
    required Color borderColor,
    required Widget icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (highlight == null || !highlightIcons.containsKey(highlight)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        if (highlight != null) {
          final messageController = Get.find<MessageController>();
          messageController.removeHighlight(messageId);
        }
      },
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 4),
        child: highlightIcons[highlight],
      ),
    );
  }
}
