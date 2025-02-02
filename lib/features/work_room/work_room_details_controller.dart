import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_details_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_details_repository.dart';

class WorkRoomDetailsController extends GetxController {

  final WorkRoomDetailsRepository workRoomDetailsRepository = WorkRoomDetailsRepository();

  Rx<WorkRoomDetails?> workRoomDetails = Rx<WorkRoomDetails?>(null);

  // 상태 변수
  var workRoom = Rxn<WorkRoom>(); // Rxn: null을 허용하는 반응형 변수
  var isLoading = false.obs; // 로딩 상태
  var errorMessage = ''.obs; // 에러 메시지
  var successMessage = ''.obs; // 성공 메시지


  Future<void> fetchWorkRoomDetails(String workRoomId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final details = await workRoomDetailsRepository.getWorkRoomDetails(workRoomId);
      workRoomDetails.value = details;
    } catch (e) {
      errorMessage.value = "Failed to load WorkRoom details: $e";
    } finally {
      isLoading.value = false;
    }
  }


}
