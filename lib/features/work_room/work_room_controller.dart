import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';

class WorkRoomController extends GetxController {
  final WorkRoomRepository _repository;

  // 상태 변수
  var workRoom = Rxn<WorkRoom>(); // Rxn: null을 허용하는 반응형 변수
  var isLoading = false.obs; // 로딩 상태
  var errorMessage = ''.obs; // 에러 메시지
  var successMessage = ''.obs; // 성공 메시지

  WorkRoomController(this._repository);

  // WorkRoom 데이터 가져오기
  Future<void> fetchWorkRoom(String workRoomId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.getWorkRoomById(workRoomId);
      workRoom.value = result;
    } catch (e) {
      errorMessage.value = 'Failed to load WorkRoom: $e';
    } finally {
      isLoading.value = false;
    }
  }


  // 새로운 WorkRoom 추가
  Future<void> addWorkRoom(String title, String description, String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      await _repository.createWorkRoom(title, description, userId);
      successMessage.value = 'WorkRoom added successfully!';
    } catch (e) {
      errorMessage.value = 'Failed to add WorkRoom: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
