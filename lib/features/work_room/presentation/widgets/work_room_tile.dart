import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/chat/data/latest_message_model.dart';
import 'package:legalfactfinder2025/features/users/presentation/widgets/user_avatar.dart';
import 'package:legalfactfinder2025/features/users/data/user_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_latest_messages_controller.dart';

class WorkRoomTile extends StatelessWidget {
  final WorkRoom workRoom;

  const WorkRoomTile({Key? key, required this.workRoom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latestMessagesController = Get.find<WorkRoomLatestMessagesController>();
    final usersController = Get.find<UsersController>();

    /// ✅ `LatestMessageModel`을 사용하여 최신 메시지 접근
    final LatestMessageModel? latestMessage = latestMessagesController.latestMessages[workRoom.id];

    final senderId = latestMessage?.lastMessageSenderId;

    /// ✅ 날짜 포맷팅 사용 (분리된 파일)
    String formattedTime = latestMessage?.lastMessageTime != null
        ? formatMessageTime(latestMessage!.lastMessageTime)
        : '';

    return InkWell(
      onTap: () {
        Get.toNamed('/work_room/${workRoom.id}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Work Room 제목
            Text(
              workRoom.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            /// 🔹 최신 메시지 + 프로필 사진 + 보낸 시간
            if (latestMessage != null)
              FutureBuilder<Map<String, UserModel>>(
                future: senderId != null ? usersController.getUsersByIds([senderId]) : null,
                builder: (context, snapshot) {
                  final senderData = snapshot.data?[senderId];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// 🔹 유저 아바타 (분리된 파일)
                      UserAvatar(imageUrl: senderData?.imageFileStorageKey),

                      /// 🔹 보낸 사람 + 메시지 내용
                      Expanded(
                        child: Text(
                          "${senderData?.username ?? '불러오는 중...'}: ${latestMessage.lastMessageContent}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),

                      /// 🔹 보낸 날짜 및 시각
                      Text(
                        formattedTime,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  );
                },
              )
            else
              Row(
                children: [
                  /// 기본 아이콘
                  const UserAvatar(),

                  /// 메시지 없음 텍스트
                  const Expanded(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
