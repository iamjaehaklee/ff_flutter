import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_repository.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkRoomRequestController extends GetxController {
  final WorkRoomRequestRepository repository = WorkRoomRequestRepository(Supabase.instance.client);

  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;
  var receivedRequests = <WorkRoomRequest>[].obs;
  var sentRequests = <WorkRoomRequest>[].obs;

  // ✅ WorkRoom 초대 요청 보내기
  Future<void> sendWorkRoomRequest(String requesterId, String recipientEmail, String workRoomId) async {
    try {
      final startTime = DateTime.now();
      debugPrint("🔄 [WorkRoomRequestController] Sending WorkRoom request from '$requesterId' to '$recipientEmail' for WorkRoom '$workRoomId' at $startTime");

      isLoading(true);
      successMessage('');
      errorMessage('');

      debugPrint("⏳ [WorkRoomRequestController] Calling repository.sendWorkRoomRequest...");
      final success = await repository.sendWorkRoomRequest(requesterId, recipientEmail, workRoomId);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint("✅ [WorkRoomRequestController] API call completed in \${duration.inMilliseconds}ms");

      if (success) {
        successMessage('WorkRoom request sent successfully.');
        debugPrint("📨 [WorkRoomRequestController] WorkRoom request successfully sent to $recipientEmail");

        fetchSentRequests(requesterId); // ✅ 보낸 요청 즉시 갱신
      } else {
        errorMessage('Failed to send WorkRoom request. User may not exist.');
        debugPrint("❌ [WorkRoomRequestController] WorkRoom request failed: User not found or another issue.");
      }
    } catch (e, stacktrace) {
      errorMessage('Error sending WorkRoom request.');
      debugPrint("❌ [WorkRoomRequestController] Exception occurred while sending WorkRoom request: $e");
      debugPrint("🔍 [WorkRoomRequestController] Stacktrace: $stacktrace");
    } finally {
      isLoading(false);
      debugPrint("🔄 [WorkRoomRequestController] Finished processing WorkRoom request.");
    }
  }

  // ✅ 받은 WorkRoom 초대 목록 불러오기
  Future<void> fetchReceivedRequests(String userId) async {
    try {
      debugPrint("🔄 [WorkRoomRequestController] Fetching received work room requests for user: $userId");

      isLoading(true);
      errorMessage('');

      List<WorkRoomRequest> requests = await repository.getReceivedRequests(userId);
      receivedRequests.assignAll(requests);

      debugPrint("✅ [WorkRoomRequestController] Successfully fetched received work room requests.");
    } catch (e, stacktrace) {
      errorMessage('❌ Error fetching received work room requests');
      debugPrint("❌ Exception: $e");
      debugPrint("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading(false);
    }
  }

  // ✅ 보낸 WorkRoom 초대 목록 불러오기
  Future<void> fetchSentRequests(String userId) async {
    try {
      debugPrint("🔄 [WorkRoomRequestController] Fetching sent work room requests for user: $userId");

      isLoading(true);
      errorMessage('');

      List<WorkRoomRequest> requests = await repository.getSentRequests(userId);
      sentRequests.assignAll(requests);

      debugPrint("✅ [WorkRoomRequestController] Successfully fetched sent work room requests.");
    } catch (e, stacktrace) {
      errorMessage('❌ Error fetching sent work room requests');
      debugPrint("❌ Exception: $e");
      debugPrint("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading(false);
    }
  }
  // ✅ WorkRoom 초대 수락/거절
  Future<void> handleWorkRoomRequest(String requestId,  String action) async {
    try {
      isLoading(true);
      successMessage('');
      errorMessage('');

      debugPrint("⏳ [WorkRoomRequestController] Processing WorkRoom request: \$requestId with action: \$action");
      final success = await repository.answerWorkRoomRequest(requestId,  action);

      if (success) {
        successMessage('WorkRoom request \$action successfully.');
        debugPrint("✅ [WorkRoomRequestController] WorkRoom request \$action successfully.");
      } else {
        errorMessage('Failed to process WorkRoom request.');
        debugPrint("❌ [WorkRoomRequestController] WorkRoom request processing failed.");
      }
    } catch (e, stacktrace) {
      errorMessage('Error processing WorkRoom request.');
      debugPrint("❌ [WorkRoomRequestController] Exception: \$e");
      debugPrint("🔍 [WorkRoomRequestController] Stacktrace: \$stacktrace");
    } finally {
      isLoading(false);
      debugPrint("🔄 [WorkRoomRequestController] Finished processing WorkRoom request.");
    }
  }
}
