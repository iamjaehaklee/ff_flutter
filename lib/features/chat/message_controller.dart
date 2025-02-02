import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/data/message_repository.dart';

class MessageController extends GetxController {
  final MessageRepository _chatRepository;

  MessageController(this._chatRepository);

  // Observable for regular messages
  var messages = <Message>[].obs;
  var isLoading = false.obs; // Loading state for regular messages

  // Fetch messages for a work room
  Future<void> loadMessages(String workRoomId, {int limit = 20, int offset = 0}) async {
    print('loadMessages with workRoomId : '  + workRoomId);
    isLoading.value = true; // Start loading
    try {
      final fetchedMessages = await _chatRepository.fetchMessages(
        workRoomId,
        limit: limit,
        offset: offset,
      );
      messages.value = fetchedMessages; // Update the observable list
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoading.value = false; // End loading
    }
  }

  // Send a message to the work room
  Future<void> sendMessage({
    required String workRoomId,
    required String senderId,
    required String content,
  }) async {
    try {
      final newMessage = await _chatRepository.sendMessage(
        workRoomId: workRoomId,
        senderId: senderId,
        content: content,
      );
      messages.insert(0, newMessage); // Add the new message to the top of the list
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
