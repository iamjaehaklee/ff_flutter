import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/users/data/users_repository.dart';
import 'package:legalfactfinder2025/features/users/data/user_model.dart';

class UsersController extends GetxController {
  final UsersRepository repository;

  UsersController(this.repository);

  var usersData = <String, UserModel>{}.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// 특정 `user_id` 리스트에 대한 사용자 정보 조회 (로드한 유저들까지 포함)
  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    Map<String, UserModel> resultUsers = Map.from(usersData);

    List<String> unknownUserIds = userIds.where((id) => !usersData.containsKey(id)).toList();

    if (unknownUserIds.isNotEmpty) {
      await _fetchAndStoreUsersByIds(unknownUserIds);
    }

    /// ✅ 비동기적으로 가져온 사용자 정보까지 포함하여 반환
    return Map.from(usersData);
  }


  Future<void> _fetchAndStoreUsersByIds(List<String> userIds) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedUsers = await repository.fetchUsersByIds(userIds);

      final Map<String, UserModel> formattedUsers = {
        for (var entry in fetchedUsers.entries)
          entry.key: UserModel.fromJson(entry.value)
      };

      usersData.addAll(formattedUsers);
    } catch (e) {
      errorMessage.value = "Failed to load users: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
