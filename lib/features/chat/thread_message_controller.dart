import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_message_repository.dart';

class ThreadMessageController extends GetxController {
  final ThreadMessageRepository _repository;

  ThreadMessageController(this._repository);

  var threadMessages = <Message>[].obs;
  var parentMessage = Rxn<Message>(); // Observable for the parent message
  var isLoading = false.obs;

  // Fetch messages in a thread
  Future<void> loadThreadMessages(String parentMessageId) async {
    isLoading.value = true; // Start loading
    try {
      // Fetch thread messages
      final fetchedMessages = await _repository.fetchThreadMessages(parentMessageId);
      threadMessages.value = fetchedMessages;

      // Fetch the parent message
      final fetchedParentMessage = await _repository.fetchParentMessage(parentMessageId);
      parentMessage.value = fetchedParentMessage;
    } catch (e) {
      print('Error loading thread messages: $e');
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Send a message in a thread
  Future<void> sendThreadMessage({
    required String workRoomId,
    required String senderId,
    required String content,
    required String parentMessageId,
  }) async {
    try {
      final newMessage = await _repository.sendThreadMessage(
        workRoomId: workRoomId,
        senderId: senderId,
        content: content,
        parentMessageId: parentMessageId,
      );
      threadMessages.add(newMessage);
    } catch (e) {
      print('Error sending thread message: $e');
    }
  }
}
