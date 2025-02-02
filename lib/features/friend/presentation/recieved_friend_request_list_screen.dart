import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_request_model.dart';
import 'package:legalfactfinder2025/features/friend/friend_request_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ReceivedFriendRequestListScreen extends StatefulWidget {
  @override
  _ReceivedFriendRequestListScreenState createState() => _ReceivedFriendRequestListScreenState();
}

class _ReceivedFriendRequestListScreenState extends State<ReceivedFriendRequestListScreen> {
  final FriendRequestController controller = Get.put(FriendRequestController());

  @override
  void initState() {
    super.initState();

    // Ensure the API call happens after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.fetchReceivedFriendRequests(userId);
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
          final FriendRequest request = controller.receivedRequests[index];
          final senderEmail = request.requesterId ?? "Unknown sender";
          final sentAt = DateFormat('yyyy-MM-dd HH:mm').format(request.sentAt);

          return ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: Text("From: $senderEmail",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Sent: $sentAt"),
            trailing: _buildRequestActions(request.id),
          );
        },
      );
    });
  }

  // Friend request accept/decline buttons
  Widget _buildRequestActions(String requestId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () {
            controller.answerFriendRequest(requestId, "accepted");
          },
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            controller.answerFriendRequest(requestId, "declined");
          },
        ),
      ],
    );
  }

  // UI when no received friend requests exist
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No received friend requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "You haven't received any friend requests yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
