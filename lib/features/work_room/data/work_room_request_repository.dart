import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkRoomRequestRepository {
  final SupabaseClient supabase;

  WorkRoomRequestRepository(this.supabase);

  // ✅ Supabase Edge Function `put_work_room_request` 호출하여 WorkRoom 요청 처리
  Future<bool> sendWorkRoomRequest(String requesterId, String recipientEmail, String workRoomId) async {
    try {
      debugPrint("🔄 [WorkRoomRequestRepository] Sending WorkRoom request from '$requesterId' to '$recipientEmail' for WorkRoom '$workRoomId'");

      final startTime = DateTime.now();
      debugPrint("⏳ [WorkRoomRequestRepository] Invoking Supabase Edge Function...");

      final responseEdge = await supabase.functions.invoke(
        'put_work_room_request',
        body: {
          'requester_id': requesterId,
          'recipient_email': recipientEmail,
          'work_room_id': workRoomId,
        },
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint("✅ [WorkRoomRequestRepository] Edge Function completed in \${duration.inMilliseconds}ms");

      if (responseEdge.data == null) {
        debugPrint("❌ [WorkRoomRequestRepository] No data received from Edge Function.");
        return false;
      }

      debugPrint("✅ [WorkRoomRequestRepository] WorkRoom request successfully sent via Edge Function.");
      return true;
    } catch (e, stacktrace) {
      debugPrint("❌ [WorkRoomRequestRepository] Error sending WorkRoom request: $e");
      debugPrint("🔍 [WorkRoomRequestRepository] Stacktrace: $stacktrace");
      return false;
    }
  }

  // ✅ 받은 WorkRoom 초대 목록 불러오기
  Future<List<WorkRoomRequest>> getReceivedRequests(String userId) async {
    try {
      debugPrint("🔄 [WorkRoomRequestRepository] Fetching received work room requests for user: $userId");

      final response = await supabase.functions.invoke(
        'get_received_work_room_requests',
        body: {'user_id': userId},
      );

      if (response.data == null) {
        debugPrint("❌ [WorkRoomRequestRepository] No data received.");
        return [];
      }

      List<dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data);
      } else if (response.data is List) {
        responseData = response.data;
      } else {
        throw Exception("Unexpected response format: \${response.data}");
      }

      debugPrint("✅ [WorkRoomRequestRepository] Successfully fetched received work room requests.");
      return responseData.map((e) => WorkRoomRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("❌ [WorkRoomRequestRepository] Error fetching received requests: $e");
      return [];
    }
  }

  // ✅ 보낸 WorkRoom 초대 목록 불러오기
  Future<List<WorkRoomRequest>> getSentRequests(String userId) async {
    try {
      debugPrint("🔄 [WorkRoomRequestRepository] Fetching sent work room requests for user: $userId");

      final response = await supabase.functions.invoke(
        'get_sent_work_room_requests',
        body: {'user_id': userId},
      );

      if (response.data == null) {
        debugPrint("❌ [WorkRoomRequestRepository] No data received.");
        return [];
      }

      List<dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data);
      } else if (response.data is List) {
        responseData = response.data;
      } else {
        throw Exception("Unexpected response format: \${response.data}");
      }

      debugPrint("✅ [WorkRoomRequestRepository] Successfully fetched sent work room requests.");
      return responseData.map((e) => WorkRoomRequest.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("❌ [WorkRoomRequestRepository] Error fetching sent requests: $e");
      return [];
    }
  }

  // ✅ WorkRoom 초대 수락/거절 처리
  Future<bool> answerWorkRoomRequest(String requestId,  String action) async {
    AuthController authController = Get.find<AuthController>();
    String? myUserId = authController.getUserId();

    if(myUserId==null){
        throw Exception("User ID is null. Cannot proceed with answering WorkRoom request.");
    }
    try {
      debugPrint("🔄 [WorkRoomRequestRepository] Answering WorkRoom request: \$requestId with action: \$action");

      final responseEdge = await supabase.functions.invoke(
        'answer_work_room_request',
        body: {
          'request_id': requestId,
          'recipient_id': myUserId,
          'action': action,
        },
      );

      if (responseEdge.data == null) {
        debugPrint("❌ [WorkRoomRequestRepository] No data received from Edge Function.");
        return false;
      }

      debugPrint("✅ [WorkRoomRequestRepository] WorkRoom request successfully answered.");
      return true;
    } catch (e, stacktrace) {
      debugPrint("❌ [WorkRoomRequestRepository] Error answering WorkRoom request: \$e");
      debugPrint("🔍 [WorkRoomRequestRepository] Stacktrace: \$stacktrace");
      return false;
    }
  }
}