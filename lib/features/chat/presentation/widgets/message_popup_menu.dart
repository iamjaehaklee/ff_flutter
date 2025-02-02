import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class MessagePopupMenu extends StatelessWidget {
  final bool isCurrentUser;
  final Message message;
  final void Function(Message)? onThreadWrite;
  final void Function(Message)? onReply;
  final void Function(Message)? onEdit;
  final void Function(Message)? onDelete;
  final void Function(Message)? onMarkImportant;

  const MessagePopupMenu({
    Key? key,
    required this.isCurrentUser,
    required this.message,
    this.onThreadWrite,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onMarkImportant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: isCurrentUser ? -60 : null,
      left: isCurrentUser ? null : -60,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCompactIcon(
                icon: Icons.comment,
                onTap: () {
                  if (onThreadWrite != null) onThreadWrite!(message);
                },
              ),
              _buildCompactIcon(
                icon: Icons.reply,
                onTap: () {
                  if (onReply != null) onReply!(message);
                },
              ),
              _buildCompactIcon(
                icon: Icons.edit,
                onTap: () {
                  if (onEdit != null) onEdit!(message);
                },
              ),
              _buildCompactIcon(
                icon: Icons.delete,
                onTap: () {
                  if (onDelete != null) onDelete!(message);
                },
              ),
              _buildCompactIcon(
                icon: Icons.star,
                onTap: () {
                  if (onMarkImportant != null) onMarkImportant!(message);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Icon(
          icon,
          size: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
