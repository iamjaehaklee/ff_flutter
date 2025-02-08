import 'dart:io';

import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/data/message_repository.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_notification.dart';
import 'package:legalfactfinder2025/core/network/api_exception.dart';

class MessageController extends GetxController {
  final MessageRepository _messageRepository;

  MessageController(this._messageRepository);

  final messages = <Message>[].obs;
  final isLoading = false.obs;

  Future<void> loadMessages(String workRoomId, {int limit = 20, int offset = 0}) async {
    isLoading.value = true;
    try {
      final fetchedMessages = await _messageRepository.fetchMessages(
        workRoomId,
        limit: limit,
        offset: offset,
      );
      messages.value = fetchedMessages;
    } on ApiException catch (e) {
      MessageNotification.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage({
    required String workRoomId,
    required String senderId,
    required String content,
    List<File>? attachments,
  }) async {
    try {
      print("[MessageController] sendMessage: Attempting to send message.");
      print("[MessageController] sendMessage: workRoomId: $workRoomId, senderId: $senderId, content: $content");
      print("[MessageController] sendMessage: attachments count: ${attachments?.length ?? 0}");

      final newMessage = await _messageRepository.sendMessage(
        workRoomId: workRoomId,
        senderId: senderId,
        content: content,
        attachments: attachments,
      );

      messages.insert(0, newMessage);
      print("[MessageController] sendMessage: Message sent successfully and inserted into messages list.");
    } on ApiException catch (e) {
      print("[MessageController] sendMessage: ApiException occurred: ${e.message}");
      MessageNotification.showError(e.message);
    } catch (e) {
      print("[MessageController] sendMessage: Unexpected error occurred: $e");
      MessageNotification.showError("Unexpected error: $e");
    }
  }


  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _messageRepository.updateMessage(messageId, newContent);
      _updateLocalMessage(
        messageId,
        (message) => message.copyWith(
          content: newContent,
          updatedAt: DateTime.now(),
        ),
      );
      MessageNotification.showSuccess('Message edited successfully');
    } on ApiException catch (e) {
      MessageNotification.showError(e.message);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _messageRepository.deleteMessage(messageId);
      messages.removeWhere((msg) => msg.id == messageId);
      MessageNotification.showSuccess('Message deleted successfully');
    } on ApiException catch (e) {
      MessageNotification.showError(e.message);
    }
  }

  Future<void> updateHighlight(String messageId, String highlight) async {
    try {
      await _messageRepository.updateHighlight(messageId, highlight);
      _updateLocalMessage(
        messageId,
        (message) => message.copyWith(
          highlight: highlight,
          updatedAt: DateTime.now(),
        ),
      );
      MessageNotification.showSuccess('Message marked successfully');
    } on ApiException catch (e) {
      MessageNotification.showError(e.message);
    }
  }

  Future<void> removeHighlight(String messageId) async {
    await updateHighlight(messageId, '');
  }

  Future<void> openThread(Message message) async {
    // 스레드 열기 로직 추가 가능
  }

  Future<void> replyToMessage(Message message) async {
    // 답장 기능 구현
  }

  Future<Message> getMessageById(String messageId) async {
    try {
      return messages.firstWhere((msg) => msg.id == messageId);
    } on StateError {
      try {
        return await _messageRepository.fetchMessageById(messageId);
      } on ApiException catch (e) {
        MessageNotification.showError(e.message);
        rethrow;
      }
    }
  }

  void _updateLocalMessage(
    String messageId,
    Message Function(Message) updateFn,
  ) {
    final index = messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      messages[index] = updateFn(messages[index]);
      messages.refresh();
    }
  }
}
