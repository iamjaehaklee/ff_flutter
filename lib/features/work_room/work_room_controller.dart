import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';

class WorkRoomController extends GetxController {
  final WorkRoomRepository _repository;

  // 현재 선택된 workRoom
  var workRoomWithParticipants = Rxn<WorkRoomWithParticipants>(); // Rxn: null 허용하는 반응형 변수



  var isLoading = false.obs; // 로딩 상태
  var errorMessage = ''.obs; // 에러 메시지
  var successMessage = ''.obs; // 성공 메시지

  WorkRoomController(this._repository) {
    print("[WorkRoomController] Constructor called.");
  } // end of Constructor





  /// [WorkRoomController.fetchWorkRoomWithParticipantsByWorkRoomId]
  /// 지정된 workRoomId에 해당하는 워크룸과 참여자 정보를 로드합니다.
  Future<void> fetchWorkRoomWithParticipantsByWorkRoomId(String workRoomId) async {
    print("[WorkRoomController.fetchWorkRoomWithParticipantsById] Start fetching work room with ID: $workRoomId");
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.getWorkRoomWithParticipantsById(workRoomId);
      workRoomWithParticipants.value = result;
      print("[WorkRoomController.fetchWorkRoomWithParticipantsById] Successfully fetched work room: ${result.toJson()}");
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load WorkRoom: $e';
      print("[WorkRoomController.fetchWorkRoomWithParticipantsById] Exception: $e");
      print("[WorkRoomController.fetchWorkRoomWithParticipantsById] Stack Trace: $stackTrace");
    } finally {
      isLoading.value = false;
      print("[WorkRoomController.fetchWorkRoomWithParticipantsById] Finished fetching work room.");
    }
  } // end of fetchWorkRoomWithParticipantsById

  /// [WorkRoomController.addWorkRoom]
  /// 새 워크룸을 추가합니다.
  Future<void> addWorkRoom(String title, String description, String userId) async {
    print("[WorkRoomController.addWorkRoom] Start adding new work room with title: $title, description: $description, userId: $userId");
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      await _repository.createWorkRoom(title, description, userId);
      successMessage.value = 'WorkRoom added successfully!';
      print("[WorkRoomController.addWorkRoom] Work room added successfully.");
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to add WorkRoom: $e';
      print("[WorkRoomController.addWorkRoom] Exception: $e");
      print("[WorkRoomController.addWorkRoom] Stack Trace: $stackTrace");
    } finally {
      isLoading.value = false;
      print("[WorkRoomController.addWorkRoom] Finished adding work room.");
    }
  } // end of addWorkRoom

  /// [WorkRoomController.updateWorkRoom]
  /// 워크룸의 제목과/또는 설명을 업데이트합니다.
  Future<void> updateWorkRoom(String workRoomId, {String? title, String? description}) async {
    print("[WorkRoomController.updateWorkRoom] Start updating work room with ID: $workRoomId, new title: $title, new description: $description");
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final updatedData = await _repository.updateWorkRoom(workRoomId, title: title, description: description);
      print("[WorkRoomController.updateWorkRoom] Updated data received: $updatedData");
      // 업데이트된 데이터를 기반으로 workRoom observable을 갱신합니다.
      workRoomWithParticipants.value = WorkRoomWithParticipants.fromJson(updatedData);
      successMessage.value = 'WorkRoom updated successfully!';
      print("[WorkRoomController.updateWorkRoom] Work room updated successfully.");
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to update WorkRoom: $e';
      print("[WorkRoomController.updateWorkRoom] Exception: $e");
      print("[WorkRoomController.updateWorkRoom] Stack Trace: $stackTrace");
      rethrow;
    } finally {
      isLoading.value = false;
      print("[WorkRoomController.updateWorkRoom] Finished updating work room.");
    }
  } // end of updateWorkRoom
}
