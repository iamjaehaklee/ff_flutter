import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/latest_message_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_latest_messages_repository.dart';


class WorkRoomLatestMessagesController extends GetxController {
  final WorkRoomLatestMessagesRepository repository;

  WorkRoomLatestMessagesController(this.repository);

  /// ✅ Work Room ID별 최신 메시지 저장 (RxMap<String, LatestMessageModel>)
  var latestMessages = <String, LatestMessageModel>{}.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// 최신 메시지를 가져오는 함수
  Future<void> fetchLatestMessages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      /// 최신 메시지 가져오기
      final fetchedMessages = await repository.fetchLatestMessages();

      /// ✅ 데이터를 `LatestMessageModel`을 사용하도록 변환하여 저장
      latestMessages.value = {
        for (var msg in fetchedMessages) msg.workRoomId: msg,
      };
    } catch (e) {
      errorMessage.value = "Failed to load latest messages: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 UI에 최신 메시지 즉시 반영
  void updateLatestMessage({required String workRoomId, required LatestMessageModel message}) {
    latestMessages[workRoomId] = message;
  }

  /// 🔹 서버에서 가져온 데이터와 비교 후 업데이트 유지
  void syncWithServer(String workRoomId, LatestMessageModel serverMessage) {
    final localMessage = latestMessages[workRoomId];

    if (localMessage == null || localMessage.lastMessageTime != serverMessage.lastMessageTime) {
      updateLatestMessage(workRoomId: workRoomId, message: serverMessage);
    }
  }
}
