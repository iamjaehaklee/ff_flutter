import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_model.dart';

class FriendListRepository {
  final SupabaseClient supabase;

  FriendListRepository(this.supabase);

  // ✅ 내 친구 목록 가져오기 (응답 구조 수정)
  Future<List<Friend>> getFriends() async {

    AuthController authController = Get.find<AuthController>();
    String? userId = authController.getUserId();
    if (userId == null) {
      print("❌ [FriendListRepository] User ID is null. Cannot fetch friends.");
      return [];
    }

    try {
      print("🔄 [FriendListRepository] Fetching friends for user ID: $userId");

      final startTime = DateTime.now(); // ✅ 요청 시작 시간 로깅
      print("⏳ [FriendListRepository] Requesting 'get_friends' from Supabase Edge Functions...");

      final response = await supabase.functions.invoke(
        'get_friends',
        body: {'user_id': userId},
      );

      final endTime = DateTime.now(); // ✅ 요청 종료 시간 로깅
      final duration = endTime.difference(startTime);
      print("✅ [FriendListRepository] Supabase Edge Function responded in ${duration.inMilliseconds}ms");

      // ✅ 응답이 Map 형태인지 확인
      if (response.data is! Map<String, dynamic>) {
        print("❌ [FriendListRepository] Unexpected API response format: ${response.data}");
        return [];
      }

      // ✅ `friends` 키가 존재하는지 확인 후 변환
      final jsonMap = response.data as Map<String, dynamic>;
      if (!jsonMap.containsKey('friends') || jsonMap['friends'] == null) {
        print("⚠️ [FriendListRepository] No friends found in response.");
        return [];
      }

      final List<dynamic> jsonList = jsonMap['friends'];
      final friends = jsonList.map((json) => Friend.fromJson(json)).toList();

      print("✅ [FriendListRepository] Successfully parsed ${friends.length} friends.");

      // ✅ 각 친구 정보 상세 로그
      for (var friend in friends) {
        print("👤 Friend - ID: ${friend.id}, Username: ${friend.username}, Is Lawyer: ${friend.isLawyer}, Profile URL: ${friend.profilePictureUrl}");
      }

      return friends;
    } catch (e, stacktrace) {
      print("❌ [FriendListRepository] Error fetching friends: $e");
      print("🔍 [FriendListRepository] Stacktrace: $stacktrace");
      throw Exception("Failed to fetch friends");
    }
  }
}
