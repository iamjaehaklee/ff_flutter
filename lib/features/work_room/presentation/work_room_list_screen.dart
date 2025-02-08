import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/latest_message_model.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_tile.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_requests_page.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_latest_messages_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
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
  late AuthController authController;
  String? userId;

  @override
  void initState() {
    super.initState();
    print("[WorkRoomListScreen.initState] Initializing controllers.");
    workRoomListController = Get.find<WorkRoomListController>();
    latestMessagesController = Get.find<WorkRoomLatestMessagesController>();
    usersController = Get.find<UsersController>();
    authController = Get.find<AuthController>();

    userId = authController.getUserId();
    if (userId == null) {
      print("[WorkRoomListScreen.initState] User ID is null.");
      return;
    }

    // Fetch work room with participants and latest messages
    workRoomListController.fetchWorkRoomsWithParticipantsByUserId(userId!);
    latestMessagesController.fetchLatestMessages();
  }

  @override
  Widget build(BuildContext context) {
    print("[WorkRoomListScreen.build] Building WorkRoomListScreen UI.");
    return Stack(
      children: [
        Positioned.fill(
          child: _buildWorkRoomList(),
        ),
        // Floating Action Button for Work Room Invitations
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
        ),
      ],
    );
  }

  void _navigateToWorkRoomRequests(BuildContext context) {
    print("[WorkRoomListScreen._navigateToWorkRoomRequests] Navigating to WorkRoomRequestsPage.");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkRoomRequestsPage()),
    );
  }

  /// Loading UI
  Widget _buildLoading() {
    print("[WorkRoomListScreen._buildLoading] Displaying loading indicator.");
    return const Center(child: CircularProgressIndicator());
  }

  /// Error UI
  Widget _buildError(String errorMessage) {
    print("[WorkRoomListScreen._buildError] Displaying error: $errorMessage");
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  /// Empty State UI
  Widget _buildEmptyState() {
    print("[WorkRoomListScreen._buildEmptyState] No work rooms found.");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
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
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                print("[WorkRoomListScreen._buildEmptyState] Navigating to AddWorkRoomPage.");
                Get.to(() => AddWorkRoomPage());
              },
              child: const Text("내 첫 Work Room 만들기"),
            ),
          ),
        ],
      ),
    );
  }

  /// Work Room List UI
  Widget _buildWorkRoomList() {
    print("[WorkRoomListScreen._buildWorkRoomList] Building work room list.");
    return Obx(() {
      // Loading state
      if (workRoomListController.isLoading.value) {
        print("[WorkRoomListScreen._buildWorkRoomList] workRoomController.isLoading is true.");
        return _buildLoading();
      }
      // Error state
      if (workRoomListController.errorMessage.isNotEmpty) {
        print("[WorkRoomListScreen._buildWorkRoomList] workRoomController.errorMessage: ${workRoomListController.errorMessage.value}");
        return _buildError(workRoomListController.errorMessage.value);
      }

      // Extract the work room list from the observable.
      List<WorkRoomWithParticipants> workRoomList = workRoomListController.workRoomWithParticipantsList;
      print("[WorkRoomListScreen._buildWorkRoomList] Retrieved workRoomList of length: ${workRoomList.length}");

      // If no work rooms, show empty state.
      if (workRoomList.isEmpty) {
        return _buildEmptyState();
      }

      // Sort the list based on latest message times.
      workRoomList.sort((a, b) {
        final LatestMessageModel? latestA = latestMessagesController.latestMessages[a.workRoom.id];
        final LatestMessageModel? latestB = latestMessagesController.latestMessages[b.workRoom.id];

        if (latestA == null && latestB == null) return 0;
        if (latestA == null) return 1;
        if (latestB == null) return -1;

        return latestB.lastMessageTime.compareTo(latestA.lastMessageTime);
      });
      print("[WorkRoomListScreen._buildWorkRoomList] Sorted work room list: ${workRoomList.map((e) => e.workRoom.title).toList()}");

      return RefreshIndicator(
        onRefresh: () async {
          print("[WorkRoomListScreen._buildWorkRoomList] Refreshing work room list.");
          await workRoomListController.fetchWorkRoomsWithParticipantsByUserId(userId!);
          await latestMessagesController.fetchLatestMessages();
        },
        color: Theme.of(context).colorScheme.secondary,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 0),
          itemCount: workRoomList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 1),
          itemBuilder: (context, index) {
            final workRoomWithParticipants = workRoomList[index];
            print("[WorkRoomListScreen._buildWorkRoomList] Building tile for work room: ${workRoomWithParticipants.workRoom.title}");
            return WorkRoomTile(workRoomWithParticipants: workRoomWithParticipants);
          },
        ),
      );
    });
  }
}
