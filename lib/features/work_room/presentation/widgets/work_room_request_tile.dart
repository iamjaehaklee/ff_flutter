import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';

class WorkRoomRequestTile extends StatelessWidget {
  final WorkRoomRequest request;

  const WorkRoomRequestTile({Key? key, required this.request})
      : super(key: key);

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    print("[WorkRoomRequestTile] build() called for request id: ${request.id}");
    return ListTile(
      leading: const Icon(Icons.mail_outline),
      title: Text(request.recipientEmail ?? "No Email",
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Status: ${request.status}"),
      trailing: Text(_formatDate(request.sentAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  } // end of build in WorkRoomRequestTile
} // end of WorkRoomRequestTile
