import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';

class WorkRoomListController extends GetxController {
  final WorkRoomRepository _repository = WorkRoomRepository();

  RxList<WorkRoomWithParticipants> workRoomWithParticipantsList = <WorkRoomWithParticipants>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  /// [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId]
  /// 지정된 userId에 해당하는 워크룸 목록(워크룸 + 참여자 정보)을 로드합니다.
  Future<void> fetchWorkRoomsWithParticipantsByUserId(String userId) async {
    print("🔵 [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId] Called with userId: $userId");
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.getWorkRoomsWithParticipantsByUserId(userId);
      workRoomWithParticipantsList.assignAll(result);
      print("✅ [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId] Successfully fetched ${result.length} work rooms.");
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load work rooms: $e';
      print("❌ [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId] Exception: $e");
      print("❌ [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId] Stack Trace: $stackTrace");
    } finally {
      isLoading.value = false;
      print("🔵 [WorkRoomController.fetchWorkRoomsWithParticipantsByUserId] Finished fetching work rooms.");
    }
  } // end of fetchWorkRoomsWithParticipantsByUserId
}
