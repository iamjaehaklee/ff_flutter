import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class ThreadMessageRepository {
  final String getThreadMessagesEdgeFunctionUrl;
  final String getParentMessageEdgeFunctionUrl; // New endpoint for parent message
  final String putThreadMessageEdgeFunctionUrl;
  final String jwtToken;

  ThreadMessageRepository({
    required this.getThreadMessagesEdgeFunctionUrl,
    required this.getParentMessageEdgeFunctionUrl,
    required this.putThreadMessageEdgeFunctionUrl,
    required this.jwtToken,
  });

  // Fetch messages in a thread
  Future<List<Message>> fetchThreadMessages(String parentMessageId) async {
    final uri = Uri.parse(
        '$getThreadMessagesEdgeFunctionUrl?parent_message_id=$parentMessageId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);

      final List<dynamic> data = jsonDecode(decodedResponse);
      return data.map((messageJson) => Message.fromJson(messageJson)).toList();
    } else {
      throw Exception("Failed to fetch thread messages: ${response.body}");
    }
  }

  // Fetch the parent message
// Fetch the parent message
  Future<Message> fetchParentMessage(String parentMessageId) async {
    final uri = Uri.parse(getParentMessageEdgeFunctionUrl);

    // Log the request for debugging
    print("Fetching parent message with ID: $parentMessageId");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
      },
      body: jsonEncode({"message_id": parentMessageId}), // Send message_id in the body
    );

    // Log the response for debugging
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);

      final data = jsonDecode(decodedResponse);
      return Message.fromJson(data);
    } else {
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

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
      },
      body: jsonEncode({
        "work_room_id": workRoomId,
        "sender_id": senderId,
        "content": content,
        "message_type": "text",
        "parent_message_id": parentMessageId,
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);

      final responseData = jsonDecode(decodedResponse);
      return Message.fromJson(responseData[0]);
    } else {
      throw Exception("Failed to send thread message: ${response.body}");
    }
  }
}
