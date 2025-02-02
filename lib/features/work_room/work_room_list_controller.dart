import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';

class WorkRoomListController extends GetxController {
  final WorkRoomRepository repository = WorkRoomRepository();

  RxList<WorkRoom> workRooms = <WorkRoom>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  /// 특정 사용자의 WorkRoom 목록을 가져오는 함수
  Future<void> fetchWorkRooms() async {
    AuthController authController= Get.find<AuthController>();
    String? userId = authController.getUserId();

    if(userId == null){
      print("User ID is null");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch work rooms from the repository
      final fetchedWorkRooms = await repository.getWorkRoomsByUserId(userId);

      // Check if the fetched work rooms are null and handle it
      if (fetchedWorkRooms == null) {
        errorMessage.value = "No work rooms found for this user.";
      } else {
        workRooms.assignAll(fetchedWorkRooms);
      }
    } catch (e) {
      errorMessage.value = "Failed to load Work Rooms: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
