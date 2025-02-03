import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/chat/data/latest_message_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_tile.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_requests_page.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_latest_messages_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/add_work_room_page.dart';

class WorkRoomListScreen extends StatefulWidget {
  WorkRoomListScreen({Key? key}) : super(key: key);

  @override
  _WorkRoomListScreenState createState() => _WorkRoomListScreenState();
}

class _WorkRoomListScreenState extends State<WorkRoomListScreen> {
  late WorkRoomListController workRoomListController;
  late WorkRoomLatestMessagesController latestMessagesController;
  late UsersController usersController;
  @override
  void initState() {
    super.initState();
    workRoomListController = Get.find<WorkRoomListController>();
    latestMessagesController = Get.find<WorkRoomLatestMessagesController>();
    usersController = Get.find<UsersController>();

    workRoomListController.fetchWorkRooms();
    latestMessagesController.fetchLatestMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildWorkRoomList(),
        ),
        // FAB 추가
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            onPressed: () {
              _navigateToWorkRoomRequests(context);
            },
            child: Icon(
              Icons.mail_outline,
              color: Colors.blue,
            ),
            tooltip: "View Work Room Invitations",
          ),
        )
      ],
    );
  }

  void _navigateToWorkRoomRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkRoomRequestsPage()),
    );
  }

  // ✅ 로딩 화면
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // ✅ 에러 화면
  Widget _buildError(String errorMessage) {
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  // ✅ Work Room이 없을 때 빈 화면 + 버튼 추가
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            // ✅ 생성된 이미지 적용
            'assets/images/workroom_placeholder.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            "아직 Work Room이 없습니다!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "새로운 Work Room을 만들어 협업을 시작하세요.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // ✅ Work Room 생성 버튼
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => AddWorkRoomPage()); // Work Room 생성 페이지 이동
              },
              child: const Text("내 첫 Work Room 만들기"),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Work Room 리스트 화면
  Widget _buildWorkRoomList() {
    return Obx(() {
      if (workRoomListController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (workRoomListController.errorMessage.isNotEmpty) {
        return Center(child: Text(workRoomListController.errorMessage.value));
      }

      /// ✅ 최신 메시지가 있는 Work Room을 먼저 정렬
      final sortedWorkRooms = List.of(workRoomListController.workRooms);
      sortedWorkRooms.sort((a, b) {
        final LatestMessageModel? latestA = latestMessagesController.latestMessages[a.id];
        final LatestMessageModel? latestB = latestMessagesController.latestMessages[b.id];

        /// ✅ 메시지가 없는 경우 정렬 기준 설정
        if (latestA == null && latestB == null) return 0;
        if (latestA == null) return 1;
        if (latestB == null) return -1;

        /// ✅ `lastMessageTime`이 `DateTime`임을 보장
        return latestB.lastMessageTime.compareTo(latestA.lastMessageTime);
      });

      return RefreshIndicator(
        onRefresh: () async {
          await workRoomListController.fetchWorkRooms();
          await latestMessagesController.fetchLatestMessages();
        },
        color: Theme.of(context).colorScheme.secondary,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 0),
          itemCount: sortedWorkRooms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 1),
          itemBuilder: (context, index) {
            final workRoom = sortedWorkRooms[index];
            return WorkRoomTile(workRoom: workRoom);
          },
        ),
      );
    });
  }


}


