import 'package:flutter/material.dart';

class MessageBubbleAvatar extends StatelessWidget {
  final String username;

  const MessageBubbleAvatar({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : "?",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
