import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/friend_request_controller.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SentFriendRequestListScreen extends StatefulWidget {
  @override
  _SentFriendRequestListScreenState createState() => _SentFriendRequestListScreenState();
}

class _SentFriendRequestListScreenState extends State<SentFriendRequestListScreen> {
  final FriendRequestController controller = Get.put(FriendRequestController());

  @override
  void initState() {
    super.initState();

    // Ensure the API call happens after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.fetchSentFriendRequests(userId);
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
          final FriendRequest request = controller.sentRequests[index];
          final recipientEmail = request.recipientEmail ?? "이메일 정보 없음";
          final isMember = request.recipientId != null ? "이 앱의 회원임" : "이 앱의 회원이 아님";
          final status = request.status;
          final sentAt = DateFormat('yyyy-MM-dd HH:mm').format(request.sentAt);

          return ListTile(
            leading: const Icon(Icons.send, color: Colors.blue),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("수신 : $recipientEmail",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$isMember",
                    style: TextStyle(color: request.recipientId != null ? Colors.green : Colors.red)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("보낸 날짜: $sentAt"),
                Text("$status", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      );
    });
  }

  // ✅ 보낸 친구 요청이 없을 때의 UI
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.outgoing_mail, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No sent friend requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "You haven't sent any friend requests yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}