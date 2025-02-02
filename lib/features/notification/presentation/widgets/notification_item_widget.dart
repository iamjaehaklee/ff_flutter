import 'package:flutter/material.dart';
import '../../data/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItemWidget({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.content),
      trailing: notification.isRead
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle, color: Colors.grey),
      onTap: onTap,
    );
  }
}
