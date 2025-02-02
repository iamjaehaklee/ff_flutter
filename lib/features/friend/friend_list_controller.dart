import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_model.dart';
import 'package:legalfactfinder2025/features/friend/data/friend_list_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendListController extends GetxController {
  final FriendListRepository repository = FriendListRepository(Supabase.instance.client);

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var friends = <Friend>[].obs;

  // ✅ 친구 목록 가져오기
  Future<void> fetchFriends() async {
    try {
      isLoading(true);
      errorMessage('');

      final result = await repository.getFriends();
      friends.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load friends.');
    } finally {
      isLoading(false);
    }
  }
}
