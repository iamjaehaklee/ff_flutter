import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_requests_page.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/add_work_room_page.dart';

class WorkRoomListScreen extends StatefulWidget {
  WorkRoomListScreen({Key? key}) : super(key: key);

  @override
  _WorkRoomListScreenState createState() => _WorkRoomListScreenState();
}

class _WorkRoomListScreenState extends State<WorkRoomListScreen> {
  late WorkRoomListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkRoomListController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
      ),
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
      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchWorkRooms();
        },
        color: Theme.of(context).colorScheme.secondary, // ✅ App Theme 색상 적용

        child: controller.isLoading.value
            ? Container(
                color: Colors.grey[400],
                child: ListView(
                  children: const [
                    SizedBox(height: 250), // 여백 추가
                    Center(child: CircularProgressIndicator()), // 로딩 표시
                  ],
                ),
              )
            : controller.errorMessage.value.isNotEmpty
                ? _buildError(controller.errorMessage.value)
                : controller.workRooms.isEmpty
                    ? _buildEmptyState()
                    : Container(
                        color: Colors.black38,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemCount: controller.workRooms.length,
                          separatorBuilder: (context, index) =>
                              const Divider(thickness: 1, height: 1),
                          itemBuilder: (context, index) {
                            final workRoom = controller.workRooms[index];
                            return WorkRoomTile(workRoom: workRoom);
                          },
                        ),
                      ),
      );
    });
  }
}

class WorkRoomTile extends StatelessWidget {
  final WorkRoom workRoom;

  const WorkRoomTile({Key? key, required this.workRoom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/work_room/${workRoom.id}');
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workRoom.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                workRoom.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: workRoom.participants.map((participant) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        avatar: CircleAvatar(
                          backgroundImage:
                              NetworkImage(participant.profilePictureUrl),
                        ),
                        label: Text(participant.username),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
