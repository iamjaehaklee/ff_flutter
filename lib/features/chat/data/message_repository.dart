import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';

class MessageRepository {
  final String getChatMessagesEdgeFunctionUrl; // Supabase Edge Function URL
  final String putChatMessageEdgeFunctionUrl;
  final String jwtToken;

  MessageRepository(
      {required this.getChatMessagesEdgeFunctionUrl,
      required this.putChatMessageEdgeFunctionUrl,
      required this.jwtToken});

  Future<List<Message>> fetchMessages(String workRoomId,
      {int limit = 20, int offset = 0}) async {
    final uri = Uri.parse(
        '$getChatMessagesEdgeFunctionUrl?work_room_id=$workRoomId&limit=$limit&offset=$offset');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final  List<dynamic> data = jsonDecode(decodedResponse);
       return data.map((messageJson) => Message.fromJson(messageJson)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${response.body}');
    }
  }

  Future<Message> sendMessage({
    required String workRoomId,
    required String senderId,
    required String content,
  }) async {
    // Validate input parameters
    if (workRoomId.isEmpty || senderId.isEmpty || content.isEmpty) {
      throw Exception(
          "Missing required parameters: workRoomId, senderId, or content");
    }

    final uri = Uri.parse(putChatMessageEdgeFunctionUrl);
    final requestBody = jsonEncode({
      "work_room_id": workRoomId,
      "sender_id": senderId,
      "content": content,
      "message_type": "text",
    });

    // Log the request for debugging
    print("Sending POST request to $uri with body: $requestBody");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    // Log the raw response for debugging
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Handle response
    if (response.statusCode == 200) {
      try {
        final decodedResponse = utf8.decode(response.bodyBytes);

        final responseData = jsonDecode(decodedResponse);
        return Message.fromJson(responseData[
            0]); // Assuming the response contains the inserted message
      } catch (e) {
        throw Exception("Failed to decode response: ${response.body}");
      }
    } else {
      // Try to parse error as JSON, otherwise return raw response
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(
            "Failed to send message: ${errorData['error'] ?? response.body}");
      } catch (_) {
        throw Exception("Failed to send message: ${response.body}");
      }
    }
  }


}
