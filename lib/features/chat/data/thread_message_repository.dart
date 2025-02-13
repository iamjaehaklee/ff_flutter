import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class ThreadMessageRepository {
  final String getThreadMessagesEdgeFunctionUrl;
  final String getParentMessageEdgeFunctionUrl;
  final String putThreadMessageEdgeFunctionUrl;
  final String updateThreadMessageEdgeFunctionUrl; // New endpoint for updating messages
  final String jwtToken;

  ThreadMessageRepository({
    required this.getThreadMessagesEdgeFunctionUrl,
    required this.getParentMessageEdgeFunctionUrl,
    required this.putThreadMessageEdgeFunctionUrl,
    required this.updateThreadMessageEdgeFunctionUrl,
    required this.jwtToken,
  });

  // Fetch messages in a thread
  Future<List<Message>> fetchThreadMessagesByParentMessageId(String parentMessageId) async {
    final uri = Uri.parse('$getThreadMessagesEdgeFunctionUrl?parent_message_id=$parentMessageId');

    print("🔵 [Thread] Fetching thread messages for parent ID: $parentMessageId");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponse);
      return data.map((messageJson) => Message.fromJson(messageJson)).toList();
    } else {
      print("❌ [Thread] Failed to fetch thread messages: ${response.body}");
      throw Exception("Failed to fetch thread messages: ${response.body}");
    }
  }

  // Fetch the parent message
  Future<Message> fetchParentMessage(String parentMessageId) async {
    final uri = Uri.parse(getParentMessageEdgeFunctionUrl);

    print("🔵 [Thread] Fetching parent message with ID: $parentMessageId");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({"message_id": parentMessageId}),
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      return Message.fromJson(data);
    } else {
      print("❌ [Thread] Failed to fetch parent message: ${response.body}");
      throw Exception("Failed to fetch parent message: ${response.body}");
    }
  }

  // Send a message in a thread
  Future<Message> sendThreadMessage({
    required String workRoomId,
    required String senderId,
    required String content,
    required String parentMessageId,
  }) async {
    final uri = Uri.parse(putThreadMessageEdgeFunctionUrl);

    print("🔵 [Thread] Sending message: $content");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "work_room_id": workRoomId,
        "sender_id": senderId,
        "content": content,
        "message_type": "text",
        "parent_message_id": parentMessageId,
      }),
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedResponse);
      return Message.fromJson(responseData[0]);
    } else {
      print("❌ [Thread] Failed to send thread message: ${response.body}");
      throw Exception("Failed to send thread message: ${response.body}");
    }
  }

  // Edit an existing message in a thread
  Future<void> updateThreadMessage(String messageId, String newContent) async {
    final uri = Uri.parse(updateThreadMessageEdgeFunctionUrl);

    print("🔵 [Thread] Editing message ID: $messageId with new content: $newContent");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "message_id": messageId,
        "new_content": newContent,
      }),
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ [Thread] Message updated successfully.");
    } else {
      print("❌ [Thread] Failed to update message: ${response.body}");
      throw Exception("Failed to update thread message: ${response.body}");
    }
  }


// ✅ Update message highlight (Replaces "mark important" function)
  Future<void> updateHighlight(String messageId, String highlight) async {
    final uri = Uri.parse(updateThreadMessageEdgeFunctionUrl);

    print("🔵 [Thread] Updating highlight for message ID: $messageId with text: '$highlight'");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "message_id": messageId,
        "highlight": highlight, // User-defined text
      }),
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ [Thread] Message highlight updated successfully.");
    } else {
      print("❌ [Thread] Failed to update highlight: ${response.body}");
      throw Exception("Failed to update chat message highlight: ${response.body}");
    }
  }

  // ✅ Delete a thread message
  Future<void> deleteThreadMessage(String messageId) async {
    final uri = Uri.parse(deleteThreadChatMessage_EdgeFunctionUrl);

    print("🔵 [Thread] Deleting message ID: $messageId");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({ "message_id": messageId }),
    );

    print("🟢 [Thread] Response status: ${response.statusCode}");
    print("🟢 Response body: ${response.body}");

    if (response.statusCode != 200) {
      print("❌ [Thread] Failed to delete message: ${response.body}");
      throw Exception("Failed to delete thread message: ${response.body}");
    }

    print("✅ [Thread] Thread message deleted successfully.");
  }
}

