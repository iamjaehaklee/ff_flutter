import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRequestRepository {
  final SupabaseClient supabase;

  FriendRequestRepository(this.supabase);

  // ✅ 친구 요청 보내기
  Future<bool> sendFriendRequest(String requesterId, String recipientEmail) async {
    bool success = false;
    try {
      debugPrint("🔄 Sending friend request from: $requesterId to $recipientEmail");
      final response = await supabase.functions.invoke(
        'put_friend_request',
        body: {
          'requester_id': requesterId,
          'recipient_email': recipientEmail,
        },
      );

      debugPrint("✅ Response received: ${response.data}");
      if (response.data == null) {
        debugPrint("❌ No data received in response.");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("❌ Error sending friend request: \$e");
      return false;
    }
  }

  // ✅ 기존 친구 요청 확인하기 (Edge Function 호출)
  Future<String?> checkExistingFriendRequest(String requesterId, String recipientEmail) async {
    try {
      debugPrint("🔄 Checking existing friend request from: $requesterId to $recipientEmail");
      final response = await supabase.functions.invoke(
        'check_existing_friend_request',
        body: {
          'requester_id': requesterId,
          'recipient_email': recipientEmail,
        },
      );

      debugPrint("✅ Response received: ${response.data}");
      if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data['sent_at'] as String?;
      }
    } catch (e) {
      debugPrint("❌ Error checking existing friend request: \$e");
    }
    return null;
  }

  // ✅ 받은 친구 요청 목록 불러오기
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    try {
      debugPrint("🔄 Fetching received friend requests for user: $userId");
      final response = await supabase.functions.invoke(
        'get_received_friend_requests',
        body: {'user_id': userId},
      );

      debugPrint("✅ Response received: ${response.data}");
      if (response.data == null) {
        debugPrint("❌ No data received.");
        return [];
      }
      if (response.data is! List) {
        debugPrint("❌ Unexpected response format: ${response.data}");
        return [];
      }
      return response.data.map((e) => FriendRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("❌ Error fetching received requests: $e");
      return [];
    }
  }

  // ✅ 친구 요청 응답하기 (승낙 또는 거절)
  Future<bool> answerFriendRequest(String requestId, String recipientId, String action) async {
    try {
      debugPrint("🔄 Processing friend request $requestId with action: $action");

      final response = await supabase.functions.invoke(
        'answer_friend_request',
        body: {
          'request_id': requestId,
          'recipient_id': recipientId,
          'action': action,
        },
      );

      debugPrint("✅ Response received: ${response.data}");
      if (response.data == null) {
        debugPrint("❌ No data received in response.");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("❌ Error answering friend request: $e");
      return false;
    }
  }


  // ✅ 보낸 친구 요청 목록 불러오기
  Future<List<FriendRequest>> getSentFriendRequests( String userId) async {
    try {
      debugPrint("🔄 Fetching sent friend requests for user: $userId");
      final response = await supabase.functions.invoke(
        'get_sent_friend_requests',
        body: {'user_id': userId},
      );

      debugPrint("✅ Raw Response received: ${jsonEncode(response.data)}");



      if (response.data is String) {
        debugPrint("❌ Response is a String instead of List. Attempting to parse JSON.");
        try {
           jsonDecode(response.data);
          debugPrint("✅ Successfully parsed JSON string into List.");
        } catch (e) {
          debugPrint("❌ JSON Parsing Error: $e");
          return [];
        }
      }

      if (jsonDecode(response.data) is List) {
        debugPrint("✅ Response is a valid List. Processing items...");
        List<FriendRequest> requests = [];
        for (var item in jsonDecode(response.data)) {
          debugPrint("🔹 Item: ${jsonEncode(item)}");
          if (item is! Map<String, dynamic>) {
            debugPrint("❌ Invalid item format. Expected Map<String, dynamic> but got: ${item.runtimeType}");
            continue;
          }
          try {
            debugPrint("🟢 Processing FriendRequest with ID: ${item['id']}");
            debugPrint("🟢 Requester ID: ${item['requester_id']}");
            debugPrint("🟢 Recipient ID: ${item['recipient_id']}");
            debugPrint("🟢 Status: ${item['status']}");
            debugPrint("🟢 Sent At: ${item['sent_at']}");
            debugPrint("🟢 Responded At: ${item['responded_at']}");
            debugPrint("🟢 Recipient Email: ${item['recipient_email']}");
            requests.add(FriendRequest.fromJson(item));
          } catch (e) {
            debugPrint("❌ Error extracting fields from FriendRequest item: $e");
          }
        }
        return requests;
      } else {
        debugPrint("❌ Unexpected response format. Data Type: ${response.data.runtimeType}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching sent requests: $e");
      return [];
    }
  }

}
