import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/audio_record/presentation/audio_recorder_page.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_request_page.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/add_work_room_page.dart';

void showMainLayoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('친구 초대'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => FriendRequestPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('회의록 생성'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AudioRecorderPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Work Room 생성'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AddWorkRoomPage());
              },
            ),
          ],
        ),
      );
    },
  );
}
