import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_message_repository.dart';

class ThreadMessageController extends GetxController {
  final ThreadMessageRepository _repository;

  ThreadMessageController(this._repository);

  var threadMessages = <Message>[].obs;
  var parentMessage = Rxn<Message>(); // Parent message observable
  var isLoading = false.obs;

  // Fetch messages in a thread
  Future<void> loadThreadMessages(String parentMessageId) async {
    isLoading.value = true;
    try {
      print("🔵 [Thread] Loading messages for parent ID: $parentMessageId");

      // Fetch thread messages
      final fetchedMessages = await _repository.fetchThreadMessages(parentMessageId);
      threadMessages.value = fetchedMessages;

      // Fetch parent message
      final fetchedParentMessage = await _repository.fetchParentMessage(parentMessageId);
      parentMessage.value = fetchedParentMessage;

      print("✅ [Thread] Successfully loaded ${fetchedMessages.length} messages.");
    } catch (e) {
      print("❌ [Thread] Error loading messages: $e");
      Get.snackbar("Error", "Failed to load thread messages.");
    } finally {
      isLoading.value = false;
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
      print("🔵 [Thread] Sending message: $content");
      final newMessage = await _repository.sendThreadMessage(
        workRoomId: workRoomId,
        senderId: senderId,
        content: content,
        parentMessageId: parentMessageId,
      );

      threadMessages.add(newMessage);
      update(); // UI 갱신
      print("✅ [Thread] Message sent successfully.");
    } catch (e) {
      print("❌ [Thread] Error sending message: $e");
      Get.snackbar("Error", "Failed to send thread message.");
    }
  }

  // Edit an existing message in a thread
  Future<void> editThreadMessage(String messageId, String newContent) async {
    try {
      print("🔵 [Thread] Editing message ID: $messageId");

      await _repository.updateThreadMessage(messageId, newContent);

      final index = threadMessages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final updatedMessage = threadMessages[index].copyWith(content: newContent);
        threadMessages[index] = updatedMessage;
        update(); // UI 갱신
        print("✅ [Thread] Message edited successfully.");
      } else {
        print("⚠️ [Thread] Message not found for editing.");
      }
    } catch (e) {
      print("❌ [Thread] Error editing message: $e");
      Get.snackbar("Error", "Failed to edit message.");
    }
  }
  Future<void> updateHighlight(String messageId, String highlight) async {
    try {
      await _repository.updateHighlight(messageId, highlight);
      Get.snackbar('Success', 'Message marked as important');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark message as important');
    }
  }
  // ✅ Delete a thread message and update UI
  Future<void> deleteThreadMessage(String messageId) async {
    try {
      await _repository.deleteThreadMessage(messageId);

      // Remove from local list
      threadMessages.removeWhere((msg) => msg.id == messageId);
      update(); // Refresh UI immediately

      Get.snackbar('Success', 'Thread message deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete thread message');
    }
  }
}
