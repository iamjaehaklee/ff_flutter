import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_request_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SentWorkRoomRequestListScreen extends StatefulWidget {
  @override
  _SentWorkRoomRequestListScreenState createState() => _SentWorkRoomRequestListScreenState();
}

class _SentWorkRoomRequestListScreenState extends State<SentWorkRoomRequestListScreen> {
  final WorkRoomRequestController controller = Get.put(WorkRoomRequestController());

  @override
  void initState() {
    super.initState();

    // Ensure the API call happens after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.fetchSentRequests(userId);
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
      if (controller.sentRequests.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        itemCount: controller.sentRequests.length,
        itemBuilder: (context, index) {
          final WorkRoomRequest request = controller.sentRequests[index];
          return ListTile(
            leading: const Icon(Icons.send, color: Colors.blue),
            title: Text("Work Room ID: \${request.workRoomId}"),
            subtitle: Text("Sent to: \${request.recipientId ?? request.recipientEmail}"),
            trailing: _buildRequestActions(request.id),
          );
        },
      );
    });
  }

  // ✅ 요청 취소 버튼
  Widget _buildRequestActions(String requestId) {
    return IconButton(
      icon: const Icon(Icons.cancel, color: Colors.red),
      onPressed: () {
        print("❌ Canceled request: \$requestId");
        // TODO: 초대 취소 처리 로직 추가
      },
    );
  }

  // ✅ 보낸 초대가 없을 때의 UI
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.outgoing_mail, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No sent work room invitations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "You haven't sent any work room invitations yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
