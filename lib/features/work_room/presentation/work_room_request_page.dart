import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_request_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkRoomRequestPage extends StatelessWidget {
  final WorkRoomRequestController controller = Get.put(WorkRoomRequestController());
  final TextEditingController emailController = TextEditingController();
  final String workRoomId;

  WorkRoomRequestPage({super.key, required this.workRoomId});

  @override
  Widget build(BuildContext context) {
    // ✅ 현재 로그인된 사용자 ID 가져오기
    final requesterId = Supabase.instance.client.auth.currentUser?.id;
    if (requesterId == null) {
      return const Center(child: Text("Please log in to send work room requests."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Send Work Room Request")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the email address of the user you want to invite to the work room.",
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

            Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final recipientEmail = emailController.text.trim();
                    if (recipientEmail.isEmpty) {
                      Get.snackbar("Error", "Please enter an email address.");
                      return;
                    }
                    controller.sendWorkRoomRequest(requesterId, recipientEmail, workRoomId);
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
