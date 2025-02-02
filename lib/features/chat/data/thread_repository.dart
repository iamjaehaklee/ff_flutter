import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/features/chat/data/thread_model.dart';

class ThreadRepository {
  final String getThreadsEdgeFunctionUrl;
  final String jwtToken;

  ThreadRepository({
    required this.getThreadsEdgeFunctionUrl,
    required this.jwtToken,
  });

  // Fetch threads for a work room
  Future<List<Thread>> fetchThreads(String workRoomId) async {
    final uri = Uri.parse(getThreadsEdgeFunctionUrl);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
      },
      body: jsonEncode({"work_room_id": workRoomId}),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> responseBody = jsonDecode(decodedResponse);
      final List<dynamic> threadsData = responseBody['threads'] ?? [];
      return threadsData.map((threadJson) => Thread.fromJson(threadJson)).toList();
    } else {
      throw Exception("Failed to fetch threads: ${response.body}");
    }
  }
}
