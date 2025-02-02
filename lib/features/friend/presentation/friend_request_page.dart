import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/friend_request_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final FriendRequestController controller = Get.find<FriendRequestController>();
  final TextEditingController emailController = TextEditingController();
  String? existingRequestDateTime;
  bool requestSent = false;

  @override
  Widget build(BuildContext context) {
    // ✅ 현재 로그인된 사용자 ID 가져오기
    final requesterId = Supabase.instance.client.auth.currentUser?.id;
    if (requesterId == null) {
      return const Center(child: Text("Please log in to send friend requests."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Send Friend Request")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the email address of the user you want to add as a friend.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "User Email",
                border: OutlineInputBorder(),
              ),

            ),
            const SizedBox(height: 20),

            if (existingRequestDateTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "이미 위 이메일 주소의 사용자에게 친구 요청을 보냈습니다.\n기존 요청 일시: $existingRequestDateTime",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            if (!requestSent && existingRequestDateTime == null)
              Obx(() {
                return controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final recipientEmail = emailController.text.trim();
                      if (recipientEmail.isEmpty) {
                        Get.snackbar("Error", "Please enter an email address.");
                        return;
                      }
                      bool success = await controller.sendFriendRequest(requesterId, recipientEmail);
                      if (success) {
                        setState(() {
                          requestSent = true;
                        });
                      }
                    },
                    child: const Text("Send Request"),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // ✅ 성공 메시지 표시
            Obx(() {
              if (controller.successMessage.isNotEmpty) {
                return Text(
                  controller.successMessage.value,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                );
              }
              return const SizedBox.shrink();
            }),

            // ✅ 오류 메시지 표시
            Obx(() {
              if (controller.errorMessage.isNotEmpty) {
                return Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
