import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_request_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecievedWorkRoomRequestListScreen extends StatefulWidget {
  @override
  _RecievedWorkRoomRequestListScreenState createState() => _RecievedWorkRoomRequestListScreenState();
}

class _RecievedWorkRoomRequestListScreenState extends State<RecievedWorkRoomRequestListScreen> {
  final WorkRoomRequestController controller = Get.put(WorkRoomRequestController());

  @override
  void initState() {
    super.initState();

    // Ensure the API call happens after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.fetchReceivedRequests(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      }
      if (controller.receivedRequests.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        itemCount: controller.receivedRequests.length,
        itemBuilder: (context, index) {
          final WorkRoomRequest request = controller.receivedRequests[index];
          return ListTile(
            leading: const Icon(Icons.meeting_room, color: Colors.blue),
            title: Text("Work Room ID: \${request.workRoomId}"),
            subtitle: Text("Invited by: \${request.requesterId}"),
            trailing: _buildRequestActions(request.id),
          );
        },
      );
    });
  }

  // ✅ 초대장 수락/거절 버튼
  Widget _buildRequestActions(String requestId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () {

              controller.handleWorkRoomRequest(requestId,  'accepted');

          },
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {

              controller.handleWorkRoomRequest(requestId,  'declined');

          },
        ),
      ],
    );
  }

  // ✅ 받은 초대가 없을 때의 UI
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No work room invitations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "You haven't received any work room invitations yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
