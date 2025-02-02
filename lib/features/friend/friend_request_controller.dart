import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_request_model.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_request_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRequestController extends GetxController {
  final FriendRequestRepository repository = FriendRequestRepository(Supabase.instance.client);

  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;
  var receivedRequests = <FriendRequest>[].obs;
  var sentRequests = <FriendRequest>[].obs;

  // ✅ 친구 요청 보내기
  Future<bool> sendFriendRequest(String requesterId, String recipientEmail) async {
    bool success = false;
    try {
      isLoading(true);
      successMessage('');
      errorMessage('');

      // ✅ 먼저 기존 친구 요청 확인
      final existingRequest = await repository.checkExistingFriendRequest(requesterId, recipientEmail);
      if (existingRequest != null) {
        errorMessage('이미 위 이메일 주소의 사용자에게 친구 요청을 보냈습니다. 기존 요청 일시: $existingRequest');
        return false;
      }

      success = await repository.sendFriendRequest(requesterId, recipientEmail);
      if (success) {
        successMessage('Friend request sent successfully.');
      } else {
        errorMessage('Failed to send friend request.');
      }
    } catch (e) {
      errorMessage('Error sending friend request: $e');
    } finally {
      isLoading(false);
    }
    return success;
  }

  // ✅ 기존 친구 요청 확인하기
  Future<String?> checkExistingRequest(String requesterId, String recipientEmail) async {
    try {
      return await repository.checkExistingFriendRequest(requesterId, recipientEmail);
    } catch (e) {
      errorMessage('Error checking existing request: $e');
      return null;
    }
  }

  // ✅ 받은 친구 요청 목록 불러오기
  Future<void> fetchReceivedFriendRequests(String userId) async {
    try {
      debugPrint("🔄 [FriendRequestController] Fetching received friend requests for user: $userId");

      isLoading(true);
      errorMessage('');

      List<FriendRequest> requests = await repository.getReceivedFriendRequests(userId);
      receivedRequests.assignAll(requests); // ✅ 객체 리스트 저장

      debugPrint("✅ [FriendRequestController] Successfully fetched received friend requests.");
    } catch (e, stacktrace) {
      errorMessage('❌ Error fetching received friend requests');
      debugPrint("❌ Exception: $e");
      debugPrint("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading(false);
    }
  }

  // ✅ 친구 요청 응답 처리
  //'accepted' or 'declined'
  Future<bool> answerFriendRequest(String requestId, String action) async {
    bool success = false;
    try {
      isLoading(true);
      successMessage('');
      errorMessage('');

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        errorMessage('User not authenticated.');
        return false;
      }

      success = await repository.answerFriendRequest(requestId, userId, action);
      if (success) {
        successMessage("Friend request $action successfully.");
        fetchReceivedFriendRequests(userId);
      } else {
        errorMessage("Failed to process friend request.");
      }
    } catch (e) {
      errorMessage("Error processing friend request: $e");
    } finally {
      isLoading(false);
    }
    return success;
  }


  // ✅ 보낸 친구 요청 목록 불러오기
  Future<void> fetchSentFriendRequests(String userId) async {
    try {
      debugPrint("🔄 [FriendRequestController] Fetching sent friend requests for user: $userId");

      isLoading(true);
      errorMessage('');

      List<FriendRequest> requests = await repository.getSentFriendRequests(userId);
      sentRequests.assignAll(requests); // ✅ 객체 리스트 저장

      debugPrint("✅ [FriendRequestController] Successfully fetched sent friend requests.");
    } catch (e, stacktrace) {
      errorMessage('❌ Error fetching sent friend requests');
      debugPrint("❌ Exception: $e");
      debugPrint("🔍 Stacktrace: $stacktrace");
    } finally {
      isLoading(false);
    }
  }
}
